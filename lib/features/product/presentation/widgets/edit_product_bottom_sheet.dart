import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/utils/product_name_formatter.dart';
import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';
import 'package:tokona/features/product/domain/dtos/update_product_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/widgets/add_product_base_form.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_tier_section.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_section.dart';
import 'package:tokona/features/product/presentation/widgets/strict_stock_banner.dart';

class EditProductBottomSheet extends StatefulWidget {
  final ProductModel product;
  final Future<bool> Function(UpdateProductDto dto) onSubmit;
  final VoidCallback onRestock;
  final List<String>? availableCategories;
  final List<String>? availableProductTypes;

  const EditProductBottomSheet({
    super.key,
    required this.product,
    required this.onSubmit,
    required this.onRestock,
    this.availableCategories,
    this.availableProductTypes,
  });

  static Future<void> show(
    BuildContext context, {
    required ProductModel product,
    required Future<bool> Function(UpdateProductDto dto) onSubmit,
    required VoidCallback onRestock,
    List<String>? availableCategories,
    List<String>? availableProductTypes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProductBottomSheet(
        product: product,
        onSubmit: onSubmit,
        onRestock: onRestock,
        availableCategories: availableCategories,
        availableProductTypes: availableProductTypes,
      ),
    );
  }

  @override
  State<EditProductBottomSheet> createState() => _EditProductBottomSheetState();
}

class _EditProductBottomSheetState extends State<EditProductBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController, _skuController, _baseUnitController;
  late final TextEditingController _stockController, _costPriceController, _sellingPriceController, _minStockAlertController;

  late String? _category;
  late String _productType;
  String? _imagePath;
  bool _clearImage = false;
  DateTime? _expiredAt;
  bool _clearExpiredAt = false;
  String? _deviceTag;
  bool _clearDeviceTag = false;
  late final List<CreateProductUnitDto> _packagingUnits;
  late final List<CreateProductPriceTierDto> _priceTiers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.name);
    _skuController = TextEditingController(text: p.sku ?? '');
    _baseUnitController = TextEditingController(text: p.baseUnit);
    _stockController = TextEditingController(text: CurrencyFormatter.formatNumber(p.stockBase));
    _costPriceController = TextEditingController(text: CurrencyFormatter.formatNumber(p.baseCostPrice));
    _sellingPriceController = TextEditingController(text: CurrencyFormatter.formatNumber(p.baseSellingPrice));
    _minStockAlertController = TextEditingController(text: CurrencyFormatter.formatNumber(p.minStockAlert));
    _category = p.category;
    _productType = p.productType;
    _imagePath = p.imagePath;
    _expiredAt = p.expiredAt;
    _deviceTag = p.deviceTag;

    _packagingUnits = p.units.map((u) => CreateProductUnitDto(
      unitName: u.unitName,
      conversionFactor: u.conversionFactor,
      costPrice: u.costPrice,
      sellingPrice: u.sellingPrice,
      barcode: u.barcode,
    )).toList();

    _priceTiers = p.priceTiers.map((t) => CreateProductPriceTierDto(
      unitName: t.unitName,
      minQuantity: t.minQuantity,
      price: t.price,
    )).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _baseUnitController.dispose();
    _stockController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _minStockAlertController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cleanName = ProductNameFormatter.clean(_nameController.text);
      final dto = UpdateProductDto(
        name: cleanName,
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        category: _category,
        productType: _productType,
        imagePath: _imagePath,
        clearImage: _clearImage,
        expiredAt: _expiredAt,
        clearExpiredAt: _clearExpiredAt,
        deviceTag: _deviceTag,
        clearDeviceTag: _clearDeviceTag,
        baseUnit: _baseUnitController.text.trim(),
        stockBase: CurrencyFormatter.parse(_stockController.text),
        minStockAlert: CurrencyFormatter.parse(_minStockAlertController.text),
        baseCostPrice: CurrencyFormatter.parse(_costPriceController.text),
        baseSellingPrice: CurrencyFormatter.parse(_sellingPriceController.text),
        packagingUnits: _packagingUnits,
        priceTiers: _priceTiers,
      );

      setState(() => _isSubmitting = true);
      final success = await widget.onSubmit(dto);
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Master Produk', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Perbarui harga, stok, nama, atau kemasan', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              StrictStockBanner(product: p, onRestock: widget.onRestock),
              const SizedBox(height: 16),
              AddProductBaseForm(
                nameController: _nameController,
                skuController: _skuController,
                baseUnitController: _baseUnitController,
                stockController: _stockController,
                costPriceController: _costPriceController,
                sellingPriceController: _sellingPriceController,
                minStockAlertController: _minStockAlertController,
                selectedCategory: _category,
                onCategoryChanged: (cat) => setState(() => _category = cat),
                selectedProductType: _productType,
                onProductTypeChanged: (type) => setState(() => _productType = type),
                isStockEditable: true,
                availableCategories: widget.availableCategories,
                availableProductTypes: widget.availableProductTypes,
                imagePath: _imagePath,
                onImageChanged: (path) => setState(() {
                  _imagePath = path;
                  _clearImage = path == null;
                }),
                expiredAt: _expiredAt,
                onExpiredAtChanged: (dt) => setState(() {
                  _expiredAt = dt;
                  _clearExpiredAt = dt == null;
                }),
                selectedDeviceTag: _deviceTag,
                onDeviceTagChanged: (dev) => setState(() {
                  _deviceTag = dev;
                  _clearDeviceTag = dev == null;
                }),
              ),
              const SizedBox(height: 20),
              PackagingTierSection(
                packagingUnits: _packagingUnits,
                baseCostPrice: CurrencyFormatter.parse(_costPriceController.text),
                onAddUnit: (unit) => setState(() => _packagingUnits.add(unit)),
                onRemoveUnit: (index) => setState(() => _packagingUnits.removeAt(index)),
              ),
              const SizedBox(height: 20),
              PriceTierSection(
                priceTiers: _priceTiers,
                baseUnit: _baseUnitController.text.trim().isNotEmpty ? _baseUnitController.text.trim() : 'Pcs',
                baseCostPrice: CurrencyFormatter.parse(_costPriceController.text),
                baseSellingPrice: CurrencyFormatter.parse(_sellingPriceController.text),
                onAddTier: (tier) => setState(() => _priceTiers.add(tier)),
                onRemoveTier: (index) => setState(() => _priceTiers.removeAt(index)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('BATAL', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
