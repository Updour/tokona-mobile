import 'package:flutter/material.dart';
import 'package:tokona/core/widgets/proof_photo_picker.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/purchase/domain/dtos/create_purchase_item_dto.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_device_chips.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_estimate_range_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_installment_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_item_list_section.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_marketplace_breakdown_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_payment_account_chips.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_product_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_status_selector.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_submit_button.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_summary_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_supplier_field.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';

class PurchaseRegularForm extends StatelessWidget {
  final TextEditingController supplierController;
  final String purchaseType;
  final ValueChanged<SupplierModel> onSupplierSelected;
  final TextEditingController invoiceController;
  final String deviceTag;
  final ValueChanged<String> onDeviceSelected;
  final String paymentAccount;
  final ValueChanged<String> onAccountSelected;
  final int installmentMonths;
  final TextEditingController installmentController;
  final ValueChanged<int> onTenorChanged;
  final VoidCallback onInstallmentChanged;
  final String status;
  final int poDays;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<int> onPoDaysChanged;
  final DateTime? estArrivalStart;
  final DateTime? estArrivalEnd;
  final ValueChanged<DateTimeRange?> onRangeChanged;
  final List<ProductModel> products;
  final List<CreatePurchaseItemDto> items;
  final ValueChanged<CreatePurchaseItemDto> onAddItem;
  final void Function(int index, CreatePurchaseItemDto updated) onEditItem;
  final ValueChanged<int> onRemoveItem;
  final TextEditingController serviceFeeController;
  final TextEditingController shippingFeeController;
  final TextEditingController shippingDiscountController;
  final TextEditingController voucherDiscountController;
  final VoidCallback onMarketplaceFeesChanged;
  final double itemsTotal;
  final double serviceFee;
  final double shippingFee;
  final double shippingDiscount;
  final double voucherDiscount;
  final TextEditingController notesController;
  final String? proofImagePath;
  final ValueChanged<String?> onImagePicked;
  final bool isSubmitting;
  final String? errorMessage;
  final VoidCallback onSubmit;

  const PurchaseRegularForm({
    super.key,
    required this.supplierController,
    required this.purchaseType,
    required this.onSupplierSelected,
    required this.invoiceController,
    required this.deviceTag,
    required this.onDeviceSelected,
    required this.paymentAccount,
    required this.onAccountSelected,
    required this.installmentMonths,
    required this.installmentController,
    required this.onTenorChanged,
    required this.onInstallmentChanged,
    required this.status,
    required this.poDays,
    required this.onStatusChanged,
    required this.onPoDaysChanged,
    required this.estArrivalStart,
    required this.estArrivalEnd,
    required this.onRangeChanged,
    required this.products,
    required this.items,
    required this.onAddItem,
    required this.onEditItem,
    required this.onRemoveItem,
    required this.serviceFeeController,
    required this.shippingFeeController,
    required this.shippingDiscountController,
    required this.voucherDiscountController,
    required this.onMarketplaceFeesChanged,
    required this.itemsTotal,
    required this.serviceFee,
    required this.shippingFee,
    required this.shippingDiscount,
    required this.voucherDiscount,
    required this.notesController,
    required this.proofImagePath,
    required this.onImagePicked,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = purchaseType == 'online';
    final isPaylater = paymentAccount.toLowerCase().contains('paylater') ||
        paymentAccount.toLowerCase().contains('spaylater') ||
        installmentMonths > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PurchaseSupplierField(
          controller: supplierController,
          purchaseType: purchaseType,
          onSupplierSelected: onSupplierSelected,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: invoiceController,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            labelText: 'No. Faktur Toko (Opsional)',
            hintText: 'Otomatis: INV-[TOKO]-[PRODUK]-[ACAK]',
            prefixIcon: Icon(Icons.receipt_outlined, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        if (isOnline) ...[
          const SizedBox(height: 8),
          PurchaseDeviceChips(
            selectedDevice: deviceTag,
            onDeviceSelected: onDeviceSelected,
          ),
        ],
        const SizedBox(height: 8),
        PurchasePaymentAccountChips(
          selectedAccount: paymentAccount,
          onAccountSelected: onAccountSelected,
        ),
        if (isPaylater)
          PurchaseInstallmentCard(
            selectedTenor: installmentMonths,
            installmentController: installmentController,
            itemsTotal: itemsTotal + serviceFee + shippingFee - shippingDiscount - voucherDiscount,
            onTenorChanged: onTenorChanged,
            onChanged: onInstallmentChanged,
          ),
        const SizedBox(height: 10),
        PurchaseStatusSelector(
          status: status,
          poDays: poDays,
          onStatusChanged: onStatusChanged,
          onPoDaysChanged: onPoDaysChanged,
        ),
        if (status != 'received') ...[
          const SizedBox(height: 8),
          PurchaseEstimateRangeCard(
            startDate: estArrivalStart ?? DateTime.now().add(Duration(days: status == 'pre_order' ? poDays : 2)),
            endDate: estArrivalEnd ?? DateTime.now().add(Duration(days: status == 'pre_order' ? poDays + 3 : 4)),
            onRangeChanged: onRangeChanged,
          ),
        ],
        const SizedBox(height: 10),
        PurchaseProductSelector(
          products: products,
          onAddItem: onAddItem,
        ),
        PurchaseItemListSection(
          items: items,
          onEditItem: onEditItem,
          onRemoveItem: onRemoveItem,
        ),
        if (isOnline) ...[
          const SizedBox(height: 8),
          PurchaseMarketplaceBreakdownCard(
            serviceFeeController: serviceFeeController,
            shippingFeeController: shippingFeeController,
            shippingDiscountController: shippingDiscountController,
            voucherDiscountController: voucherDiscountController,
            onChanged: onMarketplaceFeesChanged,
          ),
        ],
        const SizedBox(height: 10),
        PurchaseSummaryCard(
          itemsTotal: itemsTotal,
          serviceFee: serviceFee,
          shippingFee: shippingFee,
          shippingDiscount: shippingDiscount,
          voucherDiscount: voucherDiscount,
          isOnline: isOnline,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: 'Catatan (Opsional)',
            hintText: 'Nomor pesanan faktur distributor',
            prefixIcon: Icon(Icons.description_outlined, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        ProofPhotoPicker(
          imagePath: proofImagePath,
          label: isOnline ? 'Foto Nota Marketplace' : 'Foto Nota Fisik Barang',
          hint: 'Ambil foto kamera atau pilih galeri (opsional)',
          onImagePicked: onImagePicked,
        ),
        const SizedBox(height: 12),
        PurchaseSubmitButton(
          isSubmitting: isSubmitting,
          errorMessage: errorMessage,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}
