import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_fee_inputs.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_installment_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_item_list_section.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_product_selector.dart';

class EditPurchaseItemsSheet extends ConsumerStatefulWidget {
  final PurchaseModel purchase;

  const EditPurchaseItemsSheet({super.key, required this.purchase});

  static Future<void> show(BuildContext context, PurchaseModel purchase) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditPurchaseItemsSheet(purchase: purchase),
    );
  }

  @override
  ConsumerState<EditPurchaseItemsSheet> createState() => _EditPurchaseItemsSheetState();
}

class _EditPurchaseItemsSheetState extends ConsumerState<EditPurchaseItemsSheet> {
  late final TextEditingController _invoiceController;
  late final TextEditingController _supplierController;
  late final TextEditingController _notesController;
  late final TextEditingController _serviceFeeController;
  late final TextEditingController _shippingFeeController;
  late final TextEditingController _installmentController;
  late int _selectedTenor;

  final List<CreatePurchaseItemDto> _items = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.purchase;
    _invoiceController = TextEditingController(text: p.invoiceNumber);
    _supplierController = TextEditingController(text: p.supplierName ?? '');
    _notesController = TextEditingController(text: p.notes ?? '');
    _serviceFeeController = TextEditingController(text: p.serviceFee > 0 ? CurrencyFormatter.formatNumber(p.serviceFee) : '');
    _shippingFeeController = TextEditingController(text: p.shippingFee > 0 ? CurrencyFormatter.formatNumber(p.shippingFee) : '');
    _selectedTenor = p.installmentMonths > 0 ? p.installmentMonths : 1;
    _installmentController = TextEditingController(
      text: p.monthlyInstallment > 0 ? CurrencyFormatter.formatNumber(p.monthlyInstallment) : '',
    );

    for (final it in p.items) {
      _items.add(CreatePurchaseItemDto(
        productId: it.productId,
        productName: it.productName ?? 'Produk',
        unitId: it.unitId,
        unitName: it.unitName,
        quantity: it.quantity,
        conversionFactor: it.conversionFactor,
        unitCost: it.unitCost,
      ));
    }
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    _serviceFeeController.dispose();
    _shippingFeeController.dispose();
    _installmentController.dispose();
    super.dispose();
  }

  double get _itemsTotal => _items.fold(0.0, (acc, item) => acc + item.subtotal);
  double get _serviceFee => CurrencyFormatter.parse(_serviceFeeController.text);
  double get _shippingFee => CurrencyFormatter.parse(_shippingFeeController.text);
  double get _grandTotal => _itemsTotal + _serviceFee + _shippingFee;

  Future<void> _handleSave() async {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId == null) return;
    if (_items.isEmpty) {
      AppToast.showWarning(context, 'Faktur harus memiliki minimal 1 item produk');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    final success = await ref.read(purchaseControllerProvider.notifier).updatePurchaseItemsAndDetails(
      purchaseId: widget.purchase.id,
      invoiceNumber: _invoiceController.text.trim().isEmpty ? widget.purchase.invoiceNumber : _invoiceController.text.trim(),
      supplierName: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      serviceFee: _serviceFee,
      shippingFee: _shippingFee,
      installmentMonths: _selectedTenor,
      monthlyInstallment: CurrencyFormatter.parse(_installmentController.text),
      newItems: _items,
      storeId: storeId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      AppToast.showSuccess(context, 'Faktur & barang belanjaan berhasil diperbarui');
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      AppToast.showError(context, 'Gagal memperbarui faktur pembelian');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final products = productState.products;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(18, 14, 18, MediaQuery.of(context).viewInsets.bottom + 18),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit & Tambah Barang Faktur', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Nota: ${widget.purchase.invoiceNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _invoiceController,
                  decoration: _inputDeco('No. Faktur Pembelian', Icons.receipt_rounded, 'INV-9901'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _supplierController,
                  decoration: _inputDeco('Nama Supplier / Toko Kulakan', Icons.storefront_rounded, 'Grosir Makmur Jaya'),
                ),
                const SizedBox(height: 14),
                const Text('Tambah Produk ke Faktur:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                PurchaseProductSelector(
                  products: products,
                  onAddItem: (newItem) => setState(() => _items.add(newItem)),
                ),
                PurchaseItemListSection(
                  items: _items,
                  onEditItem: (idx, updated) => setState(() => _items[idx] = updated),
                  onRemoveItem: (idx) => setState(() => _items.removeAt(idx)),
                ),
                const SizedBox(height: 10),
                PurchaseFeeInputs(
                  serviceFeeController: _serviceFeeController,
                  shippingFeeController: _shippingFeeController,
                  onChanged: () => setState(() {}),
                ),
                if (widget.purchase.isPaylater)
                  PurchaseInstallmentCard(
                    selectedTenor: _selectedTenor,
                    installmentController: _installmentController,
                    itemsTotal: _itemsTotal,
                    onTenorChanged: (t) {
                      setState(() {
                        _selectedTenor = t;
                        if (t > 1 && _installmentController.text.trim().isEmpty) {
                          final estMonthly = (_itemsTotal * (1 + (0.0295 * t))) / t;
                          _installmentController.text = CurrencyFormatter.formatNumber(estMonthly);
                        }
                      });
                    },
                    onChanged: () => setState(() {}),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  decoration: _inputDeco('Catatan Faktur (Opsional)', Icons.edit_note_rounded, 'Catatan tambahan pengadaan'),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Faktur Baru:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyFormatter.format(_grandTotal),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSave,
                    icon: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
    );
  }
}
