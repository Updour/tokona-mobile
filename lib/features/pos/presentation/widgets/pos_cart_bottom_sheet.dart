import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/proof_photo_picker.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/payment/domain/models/payment_account_model.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/hold_cart_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_customer_bar.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_cart_item_tile.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_checkout_button.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_kasbon_due_date_card.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_payment_section.dart';
import 'package:tokona/features/pos/presentation/widgets/pos_receipt_dialog.dart';

class PosCartBottomSheet extends ConsumerStatefulWidget {
  const PosCartBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PosCartBottomSheet(),
    );
  }

  @override
  ConsumerState<PosCartBottomSheet> createState() => _PosCartBottomSheetState();
}

class _PosCartBottomSheetState extends ConsumerState<PosCartBottomSheet> {
  final _customerController = TextEditingController();
  final _discountController = TextEditingController();
  final _cashController = TextEditingController();
  PaymentAccountModel? _selectedAccount;
  CustomerModel? _selectedCustomer;
  bool _isKasbonSelected = false;
  String? _paymentProofPath;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final store = ref.read(authProvider).currentStore;
    if (store != null) ref.read(paymentAccountListProvider.notifier).loadAccounts(store.id);
    final cart = ref.read(cartProvider);
    _customerController.text = cart.customerName ?? '';
    if (cart.discountAmount > 0) _discountController.text = CurrencyFormatter.formatNumber(cart.discountAmount);
    _cashController.text = CurrencyFormatter.formatNumber(cart.finalAmount);

    _discountController.addListener(() {
      final val = CurrencyFormatter.parse(_discountController.text);
      ref.read(cartProvider.notifier).setDiscount(val);
    });
    _cashController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _customerController.dispose();
    _discountController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final auth = ref.read(authProvider);
    final store = auth.currentStore;
    final user = auth.currentUser;
    final cart = ref.read(cartProvider);

    if (store == null || user == null) return;
    if (cart.hasStockIssue) return AppToast.showError(context, 'Stok barang tidak cukup');

    if (_isKasbonSelected && _selectedCustomer == null) {
      return AppToast.showWarning(context, 'Pilih pelanggan terlebih dahulu untuk transaksi Kasbon');
    }

    final accounts = ref.read(paymentAccountListProvider);
    final activeAccount = _selectedAccount ?? (accounts.isNotEmpty ? accounts.firstWhere((a) => a.type == 'cash', orElse: () => accounts.first) : null);
    final isCash = !_isKasbonSelected && (activeAccount == null || activeAccount.type == 'cash');
    final cashPaid = isCash ? CurrencyFormatter.parse(_cashController.text) : cart.finalAmount;

    if (isCash && cashPaid < cart.finalAmount) return AppToast.showWarning(context, 'Uang pembayaran kurang');

    ref.read(cartProvider.notifier).setCustomerName(_customerController.text.trim());

    final sale = await ref.read(saleControllerProvider.notifier).checkout(
          storeId: store.id,
          userId: user.id,
          customerId: _selectedCustomer?.id,
          cart: cart,
          cashPaid: _isKasbonSelected ? 0 : cashPaid,
          paymentMethod: _isKasbonSelected ? 'KASBON' : (activeAccount?.name ?? 'Kas Tunai'),
          imagePath: _paymentProofPath,
          dueDate: _isKasbonSelected ? _selectedDueDate : null,
        );

    if (mounted && sale != null) {
      Navigator.of(context).pop();
      PosReceiptDialog.show(context, sale: sale, storeName: store.name, cashierName: user.fullName, customerPhone: _selectedCustomer?.phone, storeAddress: store.address, storePhone: store.phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final saleState = ref.watch(saleControllerProvider);
    final accounts = ref.watch(paymentAccountListProvider);

    ref.listen(saleControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        AppToast.showError(context, next.errorMessage!);
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(18, 14, 18, MediaQuery.of(context).viewInsets.bottom + 18),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      child: Column(
        children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 10),
          _buildHeader(cart),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PosCartCustomerBar(
                    controller: _customerController,
                    selectedCustomer: _selectedCustomer,
                    onCustomerChanged: (c) => setState(() => _selectedCustomer = c),
                  ),
                  const SizedBox(height: 10),
                  ...cart.items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return PosCartItemTile(
                      index: idx,
                      item: item,
                      onUpdateQty: (qty) => ref.read(cartProvider.notifier).updateQuantity(idx, qty),
                      onChangeUnit: (unit) => ref.read(cartProvider.notifier).changeUnit(idx, unit),
                      onRemove: () => ref.read(cartProvider.notifier).removeItem(idx),
                    );
                  }),
                  const SizedBox(height: 10),
                  PosPaymentSection(
                    subtotal: cart.subtotal,
                    discount: cart.discountAmount,
                    finalAmount: cart.finalAmount,
                    cashController: _cashController,
                    discountController: _discountController,
                    accounts: accounts,
                    selectedAccount: _selectedAccount ?? (accounts.isNotEmpty ? accounts.firstWhere((a) => a.type == 'cash', orElse: () => accounts.first) : null),
                    isKasbonSelected: _isKasbonSelected,
                    onAccountSelected: (acc) {
                      setState(() {
                        _isKasbonSelected = false;
                        _selectedAccount = acc;
                        if (acc.type != 'cash') _cashController.text = CurrencyFormatter.formatNumber(cart.finalAmount);
                      });
                    },
                    onKasbonSelected: () => setState(() => _isKasbonSelected = true),
                    onQuickCashSelected: (amount) => _cashController.text = CurrencyFormatter.formatNumber(amount),
                  ),
                  if (_isKasbonSelected)
                    PosKasbonDueDateCard(
                      selectedDueDate: _selectedDueDate,
                      onDueDateChanged: (d) => setState(() => _selectedDueDate = d),
                    ),
                  const SizedBox(height: 10),
                  ProofPhotoPicker(
                    imagePath: _paymentProofPath,
                    label: _isKasbonSelected
                        ? 'Foto Nota Kasbon / Tanda Tangan'
                        : (_selectedAccount != null && _selectedAccount!.type != 'cash'
                            ? 'Foto Bukti Transfer ${_selectedAccount!.name}'
                            : 'Foto Bukti Pembayaran / Struk'),
                    hint: 'Ambil foto kamera atau pilih galeri (opsional)',
                    onImagePicked: (p) => setState(() => _paymentProofPath = p),
                  ),
                  const SizedBox(height: 16),
                  PosCheckoutButton(
                    isProcessing: saleState.isProcessing,
                    isEmpty: cart.isEmpty,
                    isKasbon: _isKasbonSelected,
                    onCheckout: _handleCheckout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic cart) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Keranjang Kasir', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${cart.totalItemCount} jenis barang', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cart.isNotEmpty)
              _buildActionBtn(
                icon: Icons.pause_circle_rounded,
                label: 'Tahan',
                bgColor: const Color(0xFFFEF3C7),
                color: const Color(0xFFB45309),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final held = await HoldCartDialog.show(context, initialCustomerName: _customerController.text.trim());
                  if (held == true && mounted) Navigator.of(context).pop();
                },
              ),
            const SizedBox(width: 6),
            _buildActionBtn(
              icon: Icons.delete_sweep_rounded,
              label: 'Kosongkan',
              bgColor: const Color(0xFFFEE2E2),
              color: const Color(0xFFDC2626),
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
