import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';
import 'package:tokona/features/product/presentation/widgets/product_thumbnail_avatar.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_hpp_projection_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_product_picker_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_unit_selector_chips.dart';

class PurchaseProductSelector extends StatefulWidget {
  final List<ProductModel> products;
  final ValueChanged<CreatePurchaseItemDto> onAddItem;

  const PurchaseProductSelector({
    super.key,
    required this.products,
    required this.onAddItem,
  });

  @override
  State<PurchaseProductSelector> createState() => _PurchaseProductSelectorState();
}

class _PurchaseProductSelectorState extends State<PurchaseProductSelector> {
  ProductModel? _selectedProduct;
  ProductUnitModel? _selectedUnit;
  final _qtyController = TextEditingController(text: '1');
  final _costController = TextEditingController();

  @override
  void dispose() {
    _qtyController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _selectProduct(ProductModel product, {ProductUnitModel? matchingUnit}) {
    setState(() {
      _selectedProduct = product;
      _selectedUnit = matchingUnit;
      final cost = matchingUnit != null ? matchingUnit.costPrice : product.baseCostPrice;
      _costController.text = cost > 0 ? CurrencyFormatter.formatNumber(cost) : '';
    });
  }

  void _openProductPicker() => PurchaseProductPickerSheet.show(
        context,
        products: widget.products,
        onProductSelected: _selectProduct,
      );

  Future<void> _scanBarcode() async {
    final code = await CameraBarcodeScanner.scan(context, title: 'Pindai Barcode Pembelian');
    if (code == null || !mounted) return;
    for (final product in widget.products) {
      if (product.sku == code) return _selectProduct(product);
      for (final unit in product.units) {
        if (unit.barcode == code) return _selectProduct(product, matchingUnit: unit);
      }
    }
    AppToast.showWarning(context, 'Barcode $code tidak ditemukan di master produk');
  }

  void _handleAdd() {
    if (_selectedProduct == null) {
      AppToast.showWarning(context, 'Silakan pilih produk terlebih dahulu');
      return;
    }
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final cost = CurrencyFormatter.parse(_costController.text);
    if (qty <= 0 || cost < 0) {
      AppToast.showWarning(context, 'Jumlah harus lebih dari 0 dan harga beli valid');
      return;
    }
    final isBase = _selectedUnit == null;
    widget.onAddItem(CreatePurchaseItemDto(
      productId: _selectedProduct!.id,
      productName: _selectedProduct!.name,
      unitId: _selectedUnit?.id,
      unitName: isBase ? _selectedProduct!.baseUnit : _selectedUnit!.unitName,
      quantity: qty,
      conversionFactor: isBase ? 1.0 : _selectedUnit!.conversionFactor,
      unitCost: cost,
    ));
    setState(() {
      _selectedProduct = null;
      _selectedUnit = null;
      _qtyController.text = '1';
      _costController.clear();
    });
    AppToast.showSuccess(context, 'Berhasil ditambahkan ke daftar');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pilih Barang & Satuan', style: AppTypography.labelMedium),
              InkWell(
                onTap: _scanBarcode,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Pindai Kamera', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _selectedProduct == null ? _buildProductSelectorButton() : _buildSelectedProductCard(),
          if (_selectedProduct != null) ...[
            const SizedBox(height: 12),
            PurchaseUnitSelectorChips(
              product: _selectedProduct!,
              selectedUnit: _selectedUnit,
              onUnitSelected: (unit) {
                setState(() {
                  _selectedUnit = unit;
                  final cost = unit != null ? unit.costPrice : _selectedProduct!.baseCostPrice;
                  _costController.text = cost > 0 ? CurrencyFormatter.formatNumber(cost) : '';
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Jumlah', isDense: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter()],
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Harga Beli Satuan', prefixText: 'Rp ', hintText: '0', isDense: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PurchaseHppProjectionCard(
              product: _selectedProduct!,
              selectedUnit: _selectedUnit,
              quantity: double.tryParse(_qtyController.text) ?? 0,
              unitCost: CurrencyFormatter.parse(_costController.text),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 17),
              label: const Text('Tambahkan ke Daftar Belanja', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductSelectorButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProductPicker,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.35))),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.search_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cari & Pilih Produk Belanja...', style: AppTypography.labelMedium.copyWith(fontSize: 13, color: AppColors.primaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Ketik nama barang dan scan SKU', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Pilih', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Colors.white, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedProductCard() {
    final p = _selectedProduct!;
    final isOutOfStock = p.stockBase <= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ProductThumbnailAvatar(imagePath: p.imagePath, productName: p.name, size: 40, borderRadius: 10, enableViewer: false),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTypography.labelMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    if (p.sku != null && p.sku!.isNotEmpty) Text('${p.sku!} • ', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                    Text(
                      isOutOfStock ? 'Stok: 0 ${p.baseUnit}' : 'Stok: ${p.stockBase.toStringAsFixed(0)} ${p.baseUnit}',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: isOutOfStock ? AppColors.error : AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: _openProductPicker,
            icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.primary),
            label: const Text('Ganti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.5),
              side: const BorderSide(color: AppColors.primaryContainer),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
