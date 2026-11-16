import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_fee_inputs.dart';
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

  final List<CreatePurchaseItemDto> _items = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.purchase;
    _invoiceController = TextEditingController(text: p.invoiceNumber);
    _supplierController = TextEditingController(text: p.supplierName ?? '');
    _notesController = TextEditingController(text: p.notes ?? '');
    _serviceFeeController = TextEditingController(
      text: p.serviceFee > 0 ? CurrencyFormatter.formatNumber(p.serviceFee) : '',
    );
    _shippingFeeController = TextEditingController(
      text: p.shippingFee > 0 ? CurrencyFormatter.formatNumber(p.shippingFee) : '',
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

    setState(() => _isSubmitting = true);
    final success = await ref.read(purchaseControllerProvider.notifier).updatePurchaseItemsAndDetails(
      purchaseId: widget.purchase.id,
      invoiceNumber: _invoiceController.text.trim().isEmpty ? widget.purchase.invoiceNumber : _invoiceController.text.trim(),
      supplierName: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      serviceFee: _serviceFee,
      shippingFee: _shippingFee,
      newItems: _items,
      storeId: storeId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      AppToast.showSuccess(context, 'Faktur & barang belanjaan berhasil diperbarui');
      Navigator.of(context).pop(); // Tutup edit sheet
      Navigator.of(context).pop(); // Tutup detail sheet lama agar ter-refresh
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit & Tambah Barang Faktur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('Nota: ${widget.purchase.invoiceNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _invoiceController,
                  decoration: const InputDecoration(labelText: 'No. Faktur / Nota Toko', isDense: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _supplierController,
                  decoration: const InputDecoration(labelText: 'Nama Toko / Distributor', isDense: true),
                ),
                const SizedBox(height: 12),
                const Text('Tambah Produk ke Faktur:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Catatan Faktur (Opsional)', isDense: true),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surfaceInput, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Faktur Baru:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      Text(CurrencyFormatter.format(_grandTotal), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _handleSave,
            icon: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Perubahan Faktur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

