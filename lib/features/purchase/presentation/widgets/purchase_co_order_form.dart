import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_co_order_live_margin_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_co_order_partner_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_co_order_settings_card.dart';

class PurchaseCoOrderForm extends StatelessWidget {
  final List<ProductModel> products;
  final TextEditingController coPartnerController;
  final TextEditingController coTrackingController;
  final String platform;
  final ValueChanged<String> onPlatformChanged;
  final TextEditingController coProductNameController;
  final ProductModel? coSelectedProduct;
  final ValueChanged<ProductModel?> onProductSelected;
  final TextEditingController coQtyController;
  final TextEditingController coCostController;
  final TextEditingController coPricePerUnitController;
  final TextEditingController coTotalReceivedController;
  final double coQty;
  final double coTotalCost;
  final double coTotalReceived;
  final double coProfit;
  final double coMarginPercent;
  final bool isFundedByPartner;
  final ValueChanged<bool> onFundedChanged;
  final bool addToStock;
  final ValueChanged<bool> onAddToStockChanged;
  final TextEditingController coNotesController;
  final bool isSubmitting;
  final bool isFormValid;
  final VoidCallback onSubmit;
  final ValueChanged<String> onQtyChanged;
  final ValueChanged<String> onPricePerUnitChanged;
  final ValueChanged<String> onTotalReceivedChanged;

  const PurchaseCoOrderForm({
    super.key,
    required this.products,
    required this.coPartnerController,
    required this.coTrackingController,
    required this.platform,
    required this.onPlatformChanged,
    required this.coProductNameController,
    required this.coSelectedProduct,
    required this.onProductSelected,
    required this.coQtyController,
    required this.coCostController,
    required this.coPricePerUnitController,
    required this.coTotalReceivedController,
    required this.coQty,
    required this.coTotalCost,
    required this.coTotalReceived,
    required this.coProfit,
    required this.coMarginPercent,
    required this.isFundedByPartner,
    required this.onFundedChanged,
    required this.addToStock,
    required this.onAddToStockChanged,
    required this.coNotesController,
    required this.isSubmitting,
    required this.isFormValid,
    required this.onSubmit,
    required this.onQtyChanged,
    required this.onPricePerUnitChanged,
    required this.onTotalReceivedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PurchaseCoOrderPartnerCard(
          coPartnerController: coPartnerController,
          coTrackingController: coTrackingController,
          platform: platform,
          onPlatformChanged: onPlatformChanged,
        ),
        const SizedBox(height: 8),
        _buildProductAndPricingCard(context),
        const SizedBox(height: 8),
        PurchaseCoOrderSettingsCard(
          addToStock: addToStock,
          onAddToStockChanged: onAddToStockChanged,
          isFundedByPartner: isFundedByPartner,
          onFundedChanged: onFundedChanged,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: coNotesController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: 'Catatan Co-Order (Opsional)',
            hintText: ' Titipan teman kantor / bayar lunas',
            prefixIcon: Icon(Icons.notes_rounded, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ElevatedButton(
            onPressed: isFormValid && !isSubmitting ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            child: isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    coProfit > 0
                        ? 'Simpan Co-Order (+${CurrencyFormatter.format(coProfit)})'
                        : 'Simpan Co-Order Mitra',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductAndPricingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Autocomplete<ProductModel>(
            initialValue: TextEditingValue(text: coProductNameController.text),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable<ProductModel>.empty();
              return products.where((p) => p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            displayStringForOption: (option) => option.name,
            onSelected: (option) => onProductSelected(option),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              if (coProductNameController.text.isNotEmpty && controller.text != coProductNameController.text) {
                controller.text = coProductNameController.text;
              }
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Nama Barang *',
                  hintText: 'Ketik nama barang ( Kopi Mini)',
                  prefixIcon: const Icon(Icons.inventory_2_outlined, size: 18),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  suffixIcon: coSelectedProduct != null
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 17)
                      : null,
                ),
                onChanged: (val) {
                  coProductNameController.text = val;
                  if (coSelectedProduct != null && coSelectedProduct!.name != val) {
                    onProductSelected(null);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: coQtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    labelText: 'Qty (Jumlah) *',
                    hintText: '30',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: onQtyChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: coCostController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyTextInputFormatter()],
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Modal Checkout $platform *',
                    hintText: '4.821',
                    prefixText: 'Rp ',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    helperText: coQty > 1 && coTotalCost > 0
                        ? 'Modal: ${CurrencyFormatter.format(coTotalCost / coQty)}/pcs'
                        : null,
                    helperStyle: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: coPricePerUnitController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyTextInputFormatter()],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    labelText: 'Jual ke Rekan/Pcs',
                    hintText: '172',
                    prefixText: 'Rp ',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: onPricePerUnitChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: coTotalReceivedController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyTextInputFormatter()],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    labelText: 'Total Uang Diterima',
                    hintText: '5.160',
                    prefixText: 'Rp ',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: onTotalReceivedChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PurchaseCoOrderLiveMarginCard(
            coProfit: coProfit,
            coMarginPercent: coMarginPercent,
            coTotalCost: coTotalCost,
            coTotalReceived: coTotalReceived,
            platform: platform,
          ),
        ],
      ),
    );
  }
}
