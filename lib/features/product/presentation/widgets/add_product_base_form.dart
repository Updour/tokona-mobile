import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/utils/product_name_formatter.dart';
import 'package:tokona/core/utils/sku_generator.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:tokona/features/product/presentation/widgets/product_classification_fields.dart';
import 'package:tokona/features/product/presentation/widgets/product_device_selector.dart';
import 'package:tokona/features/product/presentation/widgets/product_expiry_date_field.dart';
import 'package:tokona/features/product/presentation/widgets/product_image_picker_widget.dart';

class AddProductBaseForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController skuController;
  final TextEditingController baseUnitController;
  final TextEditingController stockController;
  final TextEditingController costPriceController;
  final TextEditingController sellingPriceController;
  final TextEditingController minStockAlertController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final String selectedProductType;
  final ValueChanged<String> onProductTypeChanged;
  final bool isStockEditable;
  final ValueChanged<String>? onNameChanged;
  final List<String>? availableCategories;
  final List<String>? availableProductTypes;
  final String? imagePath;
  final ValueChanged<String?>? onImageChanged;
  final DateTime? expiredAt;
  final ValueChanged<DateTime?>? onExpiredAtChanged;
  final String? selectedDeviceTag;
  final ValueChanged<String?>? onDeviceTagChanged;

  const AddProductBaseForm({
    super.key,
    required this.nameController,
    required this.skuController,
    required this.baseUnitController,
    required this.stockController,
    required this.costPriceController,
    required this.sellingPriceController,
    required this.minStockAlertController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedProductType,
    required this.onProductTypeChanged,
    this.isStockEditable = true,
    this.onNameChanged,
    this.availableCategories,
    this.availableProductTypes,
    this.imagePath,
    this.onImageChanged,
    this.expiredAt,
    this.onExpiredAtChanged,
    this.selectedDeviceTag,
    this.onDeviceTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onImageChanged != null) ...[
          ProductImagePickerWidget(
            imagePath: imagePath,
            productName: nameController.text.isNotEmpty ? nameController.text : 'Foto Produk',
            onImageSelected: (path) => onImageChanged!(path),
            onImageRemoved: () => onImageChanged!(null),
          ),
          const SizedBox(height: 14),
        ],
        AuthTextField(
          controller: nameController,
          label: 'Nama Barang',
          hint: 'Indomie Goreng Spesial',
          isRequired: true,
          prefixIcon: Icons.inventory_2_outlined,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [ProductNameInputFormatter()],
          onChanged: (val) {
            _autoFillSkuIfNeeded(val.trim());
            onNameChanged?.call(val);
          },
          validator: (val) {
            final trimmed = val?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Nama barang wajib diisi';
            }
            if (trimmed.length < 3) {
              return 'Nama barang minimal 3 huruf';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: skuController,
          label: 'SKU',
          hint: 'SDPGRG-2810-482A',
          prefixIcon: Icons.qr_code_scanner_outlined,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.auto_fix_high_outlined, color: AppColors.primary, size: 20),
                tooltip: 'Buat SKU Otomatis',
                onPressed: () {
                  skuController.text = SkuGenerator.generate(nameController.text);
                },
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
                tooltip: 'Pindai Barcode Fisik',
                onPressed: () async {
                  final code = await CameraBarcodeScanner.scan(
                    context,
                    title: 'Pindai Barcode Produk',
                  );
                  if (code != null) {
                    skuController.text = code;
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ProductClassificationFields(
          selectedCategory: selectedCategory,
          onCategoryChanged: onCategoryChanged,
          selectedProductType: selectedProductType,
          onProductTypeChanged: onProductTypeChanged,
          minStockAlertController: minStockAlertController,
          availableCategories: availableCategories,
          availableProductTypes: availableProductTypes,
        ),
        if (onExpiredAtChanged != null) ...[
          const SizedBox(height: 12),
          ProductExpiryDateField(
            expiredAt: expiredAt,
            onChanged: onExpiredAtChanged!,
          ),
        ],
        if (onDeviceTagChanged != null) ...[
          const SizedBox(height: 12),
          ProductDeviceSelector(
            selectedDevice: selectedDeviceTag,
            onDeviceSelected: onDeviceTagChanged!,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: baseUnitController,
                label: 'Satuan Dasar',
                hint: 'Pcs / Btr / Kg',
                isRequired: true,
                prefixIcon: Icons.straighten_outlined,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                controller: stockController,
                label: isStockEditable ? 'Stok Awal' : 'Stok Fisik',
                hint: '0',
                readOnly: !isStockEditable,
                prefixIcon: isStockEditable ? Icons.layers_outlined : Icons.lock_outline_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AuthTextField(
                controller: costPriceController,
                label: 'HPP Modal (Dasar)',
                hint: '0',
                isRequired: true,
                prefixIcon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter()],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (CurrencyFormatter.parse(val) < 0) return 'Tidak valid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthTextField(
                controller: sellingPriceController,
                label: 'Harga Jual (Dasar)',
                hint: '0',
                isRequired: true,
                prefixIcon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter()],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (CurrencyFormatter.parse(val) <= 0) return 'Harus > 0';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _autoFillSkuIfNeeded(String name) {
    if (name.isEmpty) return;
    final currentSku = skuController.text.trim();
    if (currentSku.isEmpty || SkuGenerator.isGeneratedSku(currentSku)) {
      skuController.text = SkuGenerator.generate(name);
    }
  }
}
