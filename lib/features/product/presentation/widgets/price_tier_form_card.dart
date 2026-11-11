import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/product/domain/dtos/create_product_price_tier_dto.dart';

class PriceTierFormCard extends StatefulWidget {
  final String baseUnit;
  final double baseCostPrice;
  final double baseSellingPrice;
  final ValueChanged<CreateProductPriceTierDto> onAddTier;

  const PriceTierFormCard({
    super.key,
    required this.baseUnit,
    required this.baseCostPrice,
    required this.baseSellingPrice,
    required this.onAddTier,
  });

  @override
  State<PriceTierFormCard> createState() => _PriceTierFormCardState();
}

class _PriceTierFormCardState extends State<PriceTierFormCard> {
  final _minQtyController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _minQtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final qty = double.tryParse(_minQtyController.text) ?? 0;
    final price = CurrencyFormatter.parse(_priceController.text);

    if (qty <= 1) {
      AppToast.showWarning(context, 'Minimal beli harus lebih dari 1');
      return;
    }

    if (price <= 0) {
      AppToast.showWarning(context, 'Harga grosir harus lebih besar dari 0');
      return;
    }

    if (widget.baseSellingPrice > 0 && price >= widget.baseSellingPrice) {
      AppToast.showWarning(context, 'Harga grosir harus lebih murah dari harga eceran dasar');
      return;
    }

    final tier = CreateProductPriceTierDto(
      unitName: widget.baseUnit,
      minQuantity: qty,
      price: price,
    );

    widget.onAddTier(tier);
    _minQtyController.clear();
    _priceController.clear();
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
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Min. Beli (${widget.baseUnit})', isRequired: true),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _minQtyController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: '10',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Harga Grosir per ${widget.baseUnit}', isRequired: true),
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
              label: const Text('Tambah Harga Grosir', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionPreview() {
    final price = CurrencyFormatter.parse(_priceController.text);
    if (price <= 0) return const SizedBox.shrink();

    final discount = widget.baseSellingPrice > price ? widget.baseSellingPrice - price : 0.0;
    final margin = widget.baseCostPrice > 0 ? ((price - widget.baseCostPrice) / price) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Hemat: ${CurrencyFormatter.format(discount)}/unit • Margin HPP: ${margin >= 0 ? '+' : ''}${margin.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 11,
          color: margin >= 0 ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w600,
        ),
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
