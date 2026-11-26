import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/utils/product_name_formatter.dart';
import 'package:tokona/core/widgets/modern_sheet_widgets.dart';
import 'package:tokona/features/product/domain/dtos/create_product_dto.dart';
import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';
import 'package:tokona/features/product/presentation/widgets/add_product_base_form.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_tier_section.dart';
import 'package:tokona/features/product/presentation/widgets/price_tier_section.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class AddProductBottomSheet extends ConsumerStatefulWidget {
  final Future<bool> Function(CreateProductDto dto) onSubmit;
  final List<String>? availableCategories;
  final List<String>? availableProductTypes;

  const AddProductBottomSheet({
    super.key,
    required this.onSubmit,
    this.availableCategories,
    this.availableProductTypes,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<bool> Function(CreateProductDto dto) onSubmit,
    List<String>? availableCategories,
    List<String>? availableProductTypes,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddProductBottomSheet(
        onSubmit: onSubmit,
        availableCategories: availableCategories,
        availableProductTypes: availableProductTypes,
      ),
    );
  }

  @override
  ConsumerState<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends ConsumerState<AddProductBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _baseUnitController = TextEditingController(text: 'Pcs');
  final _stockController = TextEditingController(text: '0');
  final _costPriceController = TextEditingController(text: '0');
  final _sellingPriceController = TextEditingController(text: '0');
  late final TextEditingController _minStockAlertController;

  @override
  void initState() {
    super.initState();
    final defMin = ref.read(appPreferencesProvider).defaultMinStockAlert;
    _minStockAlertController = TextEditingController(text: CurrencyFormatter.formatNumber(defMin));
  }

  String? _category = 'Makanan';
  String _productType = 'Fisik';
  String? _imagePath;
  DateTime? _expiredAt;
  String? _deviceTag;
  final List<CreateProductUnitDto> _packagingUnits = [];
  final List<CreateProductPriceTierDto> _priceTiers = [];
  bool _isSubmitting = false;
  bool _showAdvanced = false;

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
      final dto = CreateProductDto(
        name: cleanName,
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        category: _category,
        productType: _productType,
        imagePath: _imagePath,
        expiredAt: _expiredAt,
        deviceTag: _deviceTag,
        baseUnit: _baseUnitController.text.trim(),
        initialStock: CurrencyFormatter.parse(_stockController.text),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernSheetHeader(
                title: 'Tambah Produk',
                subtitle: 'Isi info dasar, opsi lain bisa nanti',
                icon: Icons.add_box_rounded,
                onClose: () => Navigator.of(context).pop(),
              ),
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
                availableCategories: widget.availableCategories,
                availableProductTypes: widget.availableProductTypes,
                imagePath: _imagePath,
                onImageChanged: (path) => setState(() => _imagePath = path),
                expiredAt: _expiredAt,
                onExpiredAtChanged: (dt) => setState(() => _expiredAt = dt),
                selectedDeviceTag: _deviceTag,
                onDeviceTagChanged: (dev) => setState(() => _deviceTag = dev),
                showAdvancedFields: _showAdvanced,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _showAdvanced = !_showAdvanced);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _showAdvanced ? AppColors.primaryContainer.withValues(alpha: 0.45) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showAdvanced ? Icons.expand_less_rounded : Icons.tune_rounded,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _showAdvanced ? 'Sembunyikan Opsi Tambahan' : 'Opsi Tambahan (Foto, SKU, Kategori, Grosir)',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                        ),
                      ),
                      Icon(
                        _showAdvanced ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 240),
                crossFadeState: _showAdvanced ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 18),
                    PackagingTierSection(
                      packagingUnits: _packagingUnits,
                      baseCostPrice: CurrencyFormatter.parse(_costPriceController.text),
                      onAddUnit: (unit) => setState(() => _packagingUnits.add(unit)),
                      onRemoveUnit: (index) => setState(() => _packagingUnits.removeAt(index)),
                    ),
                    const SizedBox(height: 18),
                    PriceTierSection(
                      priceTiers: _priceTiers,
                      baseUnit: _baseUnitController.text.trim().isNotEmpty ? _baseUnitController.text.trim() : 'Pcs',
                      baseCostPrice: CurrencyFormatter.parse(_costPriceController.text),
                      baseSellingPrice: CurrencyFormatter.parse(_sellingPriceController.text),
                      onAddTier: (tier) => setState(() => _priceTiers.add(tier)),
                      onRemoveTier: (index) => setState(() => _priceTiers.removeAt(index)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: _isSubmitting ? null : AppColors.primaryGradient,
                        color: _isSubmitting ? AppColors.border : null,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                      ),
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
