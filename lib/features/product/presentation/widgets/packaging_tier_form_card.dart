import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/utils/product_name_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/product/domain/dtos/create_product_unit_dto.dart';

class PackagingTierFormCard extends StatefulWidget {
  final double baseCostPrice;
  final ValueChanged<CreateProductUnitDto> onAddUnit;

  const PackagingTierFormCard({
    super.key,
    required this.baseCostPrice,
    required this.onAddUnit,
  });

  @override
  State<PackagingTierFormCard> createState() => _PackagingTierFormCardState();
}

class _PackagingTierFormCardState extends State<PackagingTierFormCard> {
  final _nameController = TextEditingController();
  final _factorController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _factorController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final name = ProductNameFormatter.clean(_nameController.text);
    final factor = double.tryParse(_factorController.text) ?? 0;
    final sellPrice = CurrencyFormatter.parse(_priceController.text);
    final barcode = _barcodeController.text.trim();

    if (name.isEmpty || factor <= 1 || sellPrice <= 0) {
      AppToast.showWarning(context, 'Lengkapi data kemasan');
      return;
    }

    final unit = CreateProductUnitDto(
      unitName: name,
      conversionFactor: factor,
      costPrice: widget.baseCostPrice * factor,
      sellingPrice: sellPrice,
      barcode: barcode.isNotEmpty ? barcode : null,
    );

    widget.onAddUnit(unit);
    _nameController.clear();
    _factorController.clear();
    _priceController.clear();
    _barcodeController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Nama Kemasan', isRequired: true),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [ProductNameInputFormatter()],
                      decoration: const InputDecoration(
                        hintText: 'Dus / Lusin',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Isi Konversi', isRequired: true),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _factorController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: '24',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Harga Jual Kemasan', isRequired: true),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyTextInputFormatter()],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Barcode (Opsi)', isRequired: false),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        hintText: 'Barcode',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Pindai',
                          onPressed: () async {
                            final code = await CameraBarcodeScanner.scan(
                              context,
                              title: 'Pindai Barcode Kemasan',
                            );
                            if (code != null && mounted) {
                              setState(() {
                                _barcodeController.text = code;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildProjectionPreview(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _handleAdd,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tambah Kemasan', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionPreview() {
    final factor = double.tryParse(_factorController.text) ?? 0;
    final sellPrice = CurrencyFormatter.parse(_priceController.text);
    if (factor <= 1 || sellPrice <= 0 || widget.baseCostPrice <= 0) {
      return const SizedBox.shrink();
    }
    final tierHpp = widget.baseCostPrice * factor;
    final profit = sellPrice - tierHpp;
    final margin = (profit / sellPrice) * 100;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'HPP: ${CurrencyFormatter.format(tierHpp)} • Margin: +${margin.toStringAsFixed(1)}%',
        style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _fieldLabel(String label, {required bool isRequired}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: AppTypography.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
              ]
            : null,
      ),
    );
  }
}
