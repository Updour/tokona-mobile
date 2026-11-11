import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/services/whatsapp_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/utils/receipt_text_formatter.dart';
import 'package:tokona/features/pos/presentation/widgets/whatsapp_phone_input_dialog.dart';

class PosReceiptDialog extends StatelessWidget {
  final SaleModel sale;
  final String storeName;
  final String? cashierName;
  final String? customerPhone;
  final String? storeAddress;
  final String? storePhone;

  const PosReceiptDialog({
    super.key,
    required this.sale,
    required this.storeName,
    this.cashierName,
    this.customerPhone,
    this.storeAddress,
    this.storePhone,
  });

  static Future<void> show(
    BuildContext context, {
    required SaleModel sale,
    String storeName = 'Tokona Store',
    String? cashierName,
    String? customerPhone,
    String? storeAddress,
    String? storePhone,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PosReceiptDialog(
        sale: sale,
        storeName: storeName,
        cashierName: cashierName,
        customerPhone: customerPhone,
        storeAddress: storeAddress,
        storePhone: storePhone,
      ),
    );
  }

  String _getFormattedReceipt() {
    return ReceiptTextFormatter.formatReceipt(
      sale: sale,
      storeName: storeName,
      cashierName: cashierName,
      customerName: sale.customerName,
      customerPhone: customerPhone,
      storeAddress: storeAddress,
      storePhone: storePhone,
    );
  }

  void _copyReceiptText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _getFormattedReceipt()));
    HapticFeedback.lightImpact();
    AppToast.showSuccess(context, 'Struk nota berhasil disalin ke clipboard');
  }

  Future<void> _handleSendWhatsApp(BuildContext context) async {
    final receiptText = _getFormattedReceipt();

    if (customerPhone != null && customerPhone!.trim().isNotEmpty) {
      HapticFeedback.lightImpact();
      AppToast.showInfo(context, 'Membuka WhatsApp ke $customerPhone...');
      final launched = await WhatsAppService.sendReceipt(
        phone: customerPhone!,
        message: receiptText,
      );
      if (!launched && context.mounted) {
        AppToast.showWarning(context, 'Tidak dapat membuka WhatsApp. Teks nota telah disalin.');
        Clipboard.setData(ClipboardData(text: receiptText));
      }
      return;
    }

    WhatsAppPhoneInputDialog.show(context, receiptText: receiptText);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 28),
              ),
              const SizedBox(height: 10),
              Text('Transaksi Berhasil!', style: AppTypography.headingSmall.copyWith(fontSize: 18)),
              const SizedBox(height: 2),
              Text(storeName, style: AppTypography.bodySmall),
              const SizedBox(height: 4),
              Text(sale.invoiceNumber, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
              Text(dateFormat.format(sale.createdAt), style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              const Divider(height: 20),
              ...sale.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity.toStringAsFixed(0)}x ${item.unitName} ${item.productName ?? 'Produk'}',
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        currency.format(item.subtotal),
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 18),
              _buildRow('Total Belanja', currency.format(sale.totalAmount)),
              if (sale.discountAmount > 0)
                _buildRow('Diskon', '-${currency.format(sale.discountAmount)}', isAccent: true),
              _buildRow('Total Akhir', currency.format(sale.finalAmount), isBold: true),
              _buildRow('Tunai Diterima', currency.format(sale.cashPaid)),
              if (sale.paymentMethod.toUpperCase() != 'KASBON')
                _buildRow('Kembalian', currency.format(sale.changeAmount), isBold: true, isHighlight: true)
              else
                _buildRow('Status', 'KASBON', isBold: true, isAccent: true),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyReceiptText(context),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Salin Nota', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleSendWhatsApp(context),
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Kirim WA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'TRANSAKSI BARU',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isAccent = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              fontSize: isBold ? 13 : 12,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              fontSize: isBold ? 14 : 12,
              color: isHighlight
                  ? const Color(0xFF047857)
                  : (isAccent ? AppColors.warning : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
