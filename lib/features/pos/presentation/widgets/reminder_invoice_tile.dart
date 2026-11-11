import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/widgets/pay_kasbon_bottom_sheet.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_message_dialog.dart';

class ReminderInvoiceTile extends StatelessWidget {
  final SaleModel sale;
  final CustomerModel? customer;
  final String storeName;

  const ReminderInvoiceTile({
    super.key,
    required this.sale,
    required this.customer,
    required this.storeName,
  });

  void _openWhatsAppReminder(BuildContext context) {
    final customerName = sale.customerName ?? customer?.name ?? 'Pelanggan';
    final dateFormat = DateFormat('dd MMM yyyy');
    final createdStr = dateFormat.format(sale.createdAt);
    final dueStr = sale.dueDate != null ? dateFormat.format(sale.dueDate!) : 'Belum ditentukan';

    final defaultMessage =
        'Halo Kak *$customerName*! 🙏\n'
        'Semoga selalu sehat dan lancar rezekinya.\n\n'
        'Kami dari *$storeName* menginformasikan tagihan nota belanja Anda:\n'
        '🧾 No. Nota: *${sale.invoiceNumber}*\n'
        '📅 Tanggal Belanja: $createdStr\n'
        '⏰ Jatuh Tempo: *$dueStr*\n'
        '💰 Total Tagihan: *${CurrencyFormatter.format(sale.finalAmount)}*\n\n'
        'Pembayaran dapat dilakukan secara tunai di kasir toko atau via transfer.\n'
        'Mohon konfirmasinya jika sudah melakukan pembayaran ya Kak. Terima kasih banyak! 🙏';

    ReminderMessageDialog.show(
      context,
      title: 'Kirim Invoice & Tagihan',
      recipientName: customerName,
      initialPhone: customer?.phone,
      initialMessage: defaultMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy');
    final isOverdue = sale.dueDate != null && now.isAfter(sale.dueDate!);
    final daysDiff = sale.dueDate != null ? sale.dueDate!.difference(now).inDays : null;

    String dueLabel;
    Color dueColor;
    if (sale.dueDate == null) {
      dueLabel = 'Tanpa Tempo';
      dueColor = AppColors.textMuted;
    } else if (isOverdue) {
      final daysLate = now.difference(sale.dueDate!).inDays;
      dueLabel = daysLate == 0 ? 'Hari Ini Tempo!' : 'Telat $daysLate Hari';
      dueColor = AppColors.error;
    } else if (daysDiff != null && daysDiff <= 3) {
      dueLabel = daysDiff == 0 ? 'Hari Ini Tempo' : '$daysDiff Hari Lagi';
      dueColor = const Color(0xFFD97706);
    } else {
      dueLabel = 'Tempo ${dateFormat.format(sale.dueDate!)}';
      dueColor = const Color(0xFF047857);
    }

    final phone = customer?.phone;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isOverdue ? const Color(0xFFFEF2F2).withValues(alpha: 0.6) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOverdue ? const Color(0xFFFCA5A5) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        sale.customerName ?? customer?.name ?? 'Pelanggan Umum',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('($phone)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: dueColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dueLabel,
                  style: TextStyle(color: dueColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${sale.invoiceNumber} • Belanja: ${dateFormat.format(sale.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sisa Tagihan Kasbon:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  CurrencyFormatter.format(sale.finalAmount),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWhatsAppReminder(context),
                  icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                  label: const Text(
                    'Kirim Tagihan',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              ),
              if (customer != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => PayKasbonBottomSheet.show(context, customer: customer!),
                  icon: const Icon(Icons.payments_outlined, size: 14),
                  label: const Text('Bayar', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

