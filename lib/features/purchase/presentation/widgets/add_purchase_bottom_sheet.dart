import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_dto.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_channel_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_device_chips.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_fee_inputs.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_item_list_section.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_payment_account_chips.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_product_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_status_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_summary_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_supplier_field.dart';

class AddPurchaseBottomSheet extends ConsumerStatefulWidget {
  const AddPurchaseBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPurchaseBottomSheet(),
    );
  }

  @override
  ConsumerState<AddPurchaseBottomSheet> createState() => _AddPurchaseBottomSheetState();
}

class _AddPurchaseBottomSheetState extends ConsumerState<AddPurchaseBottomSheet> {
  final _supplierController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();
  final _serviceFeeController = TextEditingController();
  final _shippingFeeController = TextEditingController();

  String? _supplierId;
  String _purchaseType = 'offline';
  String _platform = 'Shopee';
  String _deviceTag = 'HP 1';
  String _paymentAccount = 'SeaBank';
  String _status = 'received';
  int _poDays = 3;

  final List<CreatePurchaseItemDto> _items = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _supplierController.dispose();
    _invoiceController.dispose();
    _notesController.dispose();
    _serviceFeeController.dispose();
    _shippingFeeController.dispose();
    super.dispose();
  }

  double get _itemsTotal => _items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get _serviceFee => CurrencyFormatter.parse(_serviceFeeController.text);
  double get _shippingFee => CurrencyFormatter.parse(_shippingFeeController.text);

  Future<void> _handleSubmit() async {
    final authState = ref.read(authProvider);
    final store = authState.currentStore;
    final user = authState.currentUser;

    if (store == null || user == null) {
      AppToast.showError(context, 'Sesi toko tidak ditemukan. Silakan login kembali.');
      return;
    }
    if (_items.isEmpty) {
      AppToast.showWarning(context, 'Pilih minimal 1 barang belanjaan');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final dto = CreatePurchaseDto(
        storeId: store.id, userId: user.id,
        invoiceNumber: _invoiceController.text.trim().isEmpty ? null : _invoiceController.text.trim(),
        supplierId: _supplierId, supplierName: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
        purchaseType: _purchaseType, platform: _purchaseType == 'online' ? _platform : null,
        deviceTag: _purchaseType == 'online' ? _deviceTag : null, paymentAccount: _paymentAccount,
        serviceFee: _serviceFee, shippingFee: _shippingFee, status: _status,
        poDays: _status == 'pre_order' ? _poDays : null,
        estimatedArrival: _status == 'pre_order' ? DateTime.now().add(Duration(days: _poDays)) : null,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(), items: _items,
      );

      final result = await ref.read(purchaseControllerProvider.notifier).recordPurchase(dto);
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (result != null) {
        final msg = _status == 'received' ? 'Pembelian berhasil disimpan.' : 'Pesanan dicatat via $_paymentAccount ($_deviceTag).';
        AppToast.showSuccess(context, msg);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      } else {
        final errorMsg = ref.read(purchaseControllerProvider).errorMessage ?? 'Gagal menyimpan pembelian';
        setState(() => _errorMessage = errorMsg);
        AppToast.showError(context, errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isSubmitting = false; _errorMessage = e.toString(); });
        AppToast.showError(context, 'Terjadi kendala: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productListProvider).products;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Catat Pembelian Barang', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('Pemasok offline dan online', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PurchaseChannelSelector(
                      purchaseType: _purchaseType,
                      platform: _platform,
                      onTypeChanged: (type) => setState(() => _purchaseType = type),
                      onPlatformChanged: (p) => setState(() => _platform = p),
                    ),
                    const SizedBox(height: 12),
                    PurchaseSupplierField(
                      controller: _supplierController,
                      purchaseType: _purchaseType,
                      onSupplierSelected: (selected) {
                        setState(() {
                          _supplierId = selected.id;
                          _supplierController.text = selected.name;
                          _purchaseType = selected.type;
                          if (selected.platform != null) _platform = selected.platform!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _invoiceController,
                      decoration: const InputDecoration(
                        labelText: 'No. Faktur / Nota Toko (Opsional)',
                        hintText: 'Otomatis: INV-[TOKO]-[PRODUK]-[ACAK]',
                        prefixIcon: Icon(Icons.receipt_outlined, size: 20),
                      ),
                    ),
                    if (_purchaseType == 'online') ...[
                      const SizedBox(height: 12),
                      PurchaseDeviceChips(selectedDevice: _deviceTag, onDeviceSelected: (d) => setState(() => _deviceTag = d)),
                    ],
                    const SizedBox(height: 12),
                    PurchasePaymentAccountChips(selectedAccount: _paymentAccount, onAccountSelected: (acc) => setState(() => _paymentAccount = acc)),
                    const SizedBox(height: 14),
                    PurchaseStatusSelector(
                      status: _status,
                      poDays: _poDays,
                      onStatusChanged: (s) => setState(() => _status = s),
                      onPoDaysChanged: (d) => setState(() => _poDays = d),
                    ),
                    const SizedBox(height: 14),
                    PurchaseProductSelector(products: products, onAddItem: (item) => setState(() => _items.add(item))),
                    PurchaseItemListSection(
                      items: _items,
                      onEditItem: (idx, updated) => setState(() => _items[idx] = updated),
                      onRemoveItem: (idx) => setState(() => _items.removeAt(idx)),
                    ),
                    if (_purchaseType == 'online') ...[
                      const SizedBox(height: 12),
                      PurchaseFeeInputs(
                        serviceFeeController: _serviceFeeController,
                        shippingFeeController: _shippingFeeController,
                        onChanged: () => setState(() {}),
                      ),
                    ],
                    const SizedBox(height: 14),
                    PurchaseSummaryCard(
                      itemsTotal: _itemsTotal,
                      serviceFee: _serviceFee,
                      shippingFee: _shippingFee,
                      isOnline: _purchaseType == 'online',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (Opsional)',
                        hintText: 'Nomor pesanan faktur distributor',
                        prefixIcon: Icon(Icons.description_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('SIMPAN PEMBELIAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
