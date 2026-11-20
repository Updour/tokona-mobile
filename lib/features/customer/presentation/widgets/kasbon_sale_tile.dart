import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/presentation/widgets/pay_kasbon_bottom_sheet.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_message_dialog.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class KasbonSaleTile extends ConsumerWidget {
  final SaleModel sale;
  final CustomerModel? customer;
  final DateTime now;
  final String? storeName;

  const KasbonSaleTile({
    super.key,
    required this.sale,
    required this.customer,
    required this.now,
    this.storeName,
  });

  void _sendWhatsAppReminder(BuildContext context, WidgetRef ref) {
    final customerName = sale.customerName ?? customer?.name ?? 'Pelanggan';
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final createdStr = dateFormat.format(sale.createdAt);
    final dueStr = sale.dueDate != null ? dateFormat.format(sale.dueDate!) : 'Belum ditentukan';
    final nameStore = storeName ?? 'Toko';
    final template = ref.read(appPreferencesProvider).waKasbonTemplate;

    final message = AppPreferences.renderTemplate(template, {
      'nama': customerName,
      'toko': nameStore,
      'no_nota': sale.invoiceNumber,
      'tanggal': createdStr,
      'jatuh_tempo': dueStr,
      'total': CurrencyFormatter.format(sale.finalAmount),
    });

    ReminderMessageDialog.show(
      context,
      title: 'Kirim Tagihan Kasbon WA',
      recipientName: customerName,
      initialPhone: customer?.phone,
      initialMessage: message,
      category: 'kasbon',
      referenceId: 'kasbon_${sale.id}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final isOverdue = sale.dueDate != null && now.isAfter(sale.dueDate!);
    final daysDiff = sale.dueDate != null ? sale.dueDate!.difference(now).inDays : null;

    String dueLabel;
    Color dueColor;
    if (sale.dueDate == null) {
      dueLabel = 'Tanpa Batas Waktu';
      dueColor = AppColors.textMuted;
    } else if (isOverdue) {
      final daysLate = now.difference(sale.dueDate!).inDays;
      dueLabel = daysLate == 0 ? 'Hari Ini Jatuh Tempo!' : 'Telat $daysLate Hari';
      dueColor = AppColors.error;
    } else if (daysDiff != null && daysDiff <= 3) {
      dueLabel = daysDiff == 0 ? 'Hari Ini Jatuh Tempo' : '$daysDiff Hari Lagi';
      dueColor = const Color(0xFFD97706);
    } else {
      dueLabel = 'Tempo ${dateFormat.format(sale.dueDate!)}';
      dueColor = const Color(0xFF047857);
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isOverdue ? const Color(0xFFFEF2F2).withValues(alpha: 0.6) : AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOverdue ? const Color(0xFFFCA5A5) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sale.customerName ?? 'Pelanggan Umum',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  overflow: TextOverflow.ellipsis,
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
            '${sale.invoiceNumber} • Transaksi: ${dateFormat.format(sale.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(sale.finalAmount),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _sendWhatsAppReminder(context, ref),
                    icon: const Icon(Icons.send_rounded, size: 12, color: Color(0xFF059669)),
                    label: const Text('WA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF059669))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFA7F3D0)),
                      backgroundColor: const Color(0xFFECFDF5),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4.5),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (customer != null) ...[
                    const SizedBox(width: 5),
                    ElevatedButton.icon(
                      onPressed: () {
                        PayKasbonBottomSheet.show(context, customer: customer!);
                      },
                      icon: const Icon(Icons.payments_outlined, size: 12),
                      label: const Text('Bayar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

