import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/product/data/repositories/classification_repository.dart';

class ProductClassificationFields extends StatefulWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final String selectedProductType;
  final ValueChanged<String> onProductTypeChanged;
  final TextEditingController minStockAlertController;
  final List<String>? availableCategories;
  final List<String>? availableProductTypes;

  const ProductClassificationFields({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedProductType,
    required this.onProductTypeChanged,
    required this.minStockAlertController,
    this.availableCategories,
    this.availableProductTypes,
  });

  @override
  State<ProductClassificationFields> createState() => _ProductClassificationFieldsState();
}

class _ProductClassificationFieldsState extends State<ProductClassificationFields> {
  late String _selectedCategoryOption;
  late String _selectedTypeOption;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _customTypeController;

  List<String> get _categories {
    final list = widget.availableCategories ?? ClassificationRepository.defaultCategories;
    final Set<String> set = {...list};
    set.remove('Lainnya');
    return [...set, 'Lainnya'];
  }

  List<String> get _productTypes {
    final list = widget.availableProductTypes ?? ClassificationRepository.defaultProductTypes;
    final Set<String> set = {...list};
    set.remove('Lainnya');
    return [...set, 'Lainnya'];
  }

  @override
  void initState() {
    super.initState();
    _customCategoryController = TextEditingController();
    _customTypeController = TextEditingController();
    _initSelections();
  }

  void _initSelections() {
    final cat = widget.selectedCategory?.trim();
    final allCats = _categories;
    if (cat != null && cat.isNotEmpty) {
      if (allCats.contains(cat) && cat != 'Lainnya') {
        _selectedCategoryOption = cat;
      } else {
        _selectedCategoryOption = 'Lainnya';
        _customCategoryController.text = cat;
      }
    } else {
      _selectedCategoryOption = allCats.first;
    }

    final pType = widget.selectedProductType.trim();
    final allTypes = _productTypes;
    if (pType.isNotEmpty) {
      if (allTypes.contains(pType) && pType != 'Lainnya') {
        _selectedTypeOption = pType;
      } else {
        _selectedTypeOption = 'Lainnya';
        _customTypeController.text = pType;
      }
    } else {
      _selectedTypeOption = allTypes.contains('Fisik') ? 'Fisik' : allTypes.first;
    }
  }

  @override
  void didUpdateWidget(covariant ProductClassificationFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.selectedProductType != widget.selectedProductType ||
        oldWidget.availableCategories != widget.availableCategories ||
        oldWidget.availableProductTypes != widget.availableProductTypes) {
      _initSelections();
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCategoryDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildProductTypeDropdown()),
          ],
        ),
        if (_selectedCategoryOption == 'Lainnya') ...[
          const SizedBox(height: 12),
          AuthTextField(
            controller: _customCategoryController,
            label: 'Nama Kategori Kustom',
            hint: 'Ketik nama kategori baru',
            isRequired: true,
            prefixIcon: Icons.edit_note_rounded,
            onChanged: (val) => widget.onCategoryChanged(val.trim()),
          ),
        ],
        if (_selectedTypeOption == 'Lainnya') ...[
          const SizedBox(height: 12),
          AuthTextField(
            controller: _customTypeController,
            label: 'Nama Tipe Kustom',
            hint: 'Ketik tipe barang baru',
            isRequired: true,
            prefixIcon: Icons.edit_note_rounded,
            onChanged: (val) {
              final trimmed = val.trim();
              widget.onProductTypeChanged(trimmed.isEmpty ? 'Lainnya' : trimmed);
            },
          ),
        ],
        const SizedBox(height: 12),
        AuthTextField(
          controller: widget.minStockAlertController,
          label: 'Batas Peringatan Stok Menipis',
          hint: '0',
          prefixIcon: Icons.notification_important_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyTextInputFormatter()],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    final items = _categories;
    final currentVal = items.contains(_selectedCategoryOption) ? _selectedCategoryOption : 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('cat_$currentVal'),
          initialValue: currentVal,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category_outlined, size: 20, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: items.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() => _selectedCategoryOption = val);
            if (val == 'Lainnya') {
              final custom = _customCategoryController.text.trim();
              widget.onCategoryChanged(custom.isEmpty ? null : custom);
            } else {
              widget.onCategoryChanged(val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildProductTypeDropdown() {
    final items = _productTypes;
    final currentVal = items.contains(_selectedTypeOption) ? _selectedTypeOption : 'Lainnya';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Barang',
          style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('type_$currentVal'),
          initialValue: currentVal,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.widgets_outlined, size: 20, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: items.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() => _selectedTypeOption = val);
            if (val == 'Lainnya') {
              final custom = _customTypeController.text.trim();
              widget.onProductTypeChanged(custom.isEmpty ? 'Lainnya' : custom);
            } else {
              widget.onProductTypeChanged(val);
            }
          },
        ),
      ],
    );
  }
}
