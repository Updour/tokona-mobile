import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/pos/data/services/whatsapp_reminder_service.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/domain/models/wa_message_log.dart';
import 'package:tokona/features/pos/presentation/controllers/wa_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_message_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_tab_helpers.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';

class WaHistoryTabView extends ConsumerStatefulWidget {
  final List<HeldCartModel> heldOrders;
  final List<SaleModel> kasbonSales;
  final List<CustomerModel> customers;
  final String storeName;
  final String searchQuery;

  const WaHistoryTabView({
    super.key,
    required this.heldOrders,
    required this.kasbonSales,
    required this.customers,
    required this.storeName,
    required this.searchQuery,
  });

  @override
  ConsumerState<WaHistoryTabView> createState() => _WaHistoryTabViewState();
}

class _WaHistoryTabViewState extends ConsumerState<WaHistoryTabView> {
  String _filter = 'semua'; // semua, pending, sent, failed

  List<WaMessageLog> _buildCombinedList(List<WaMessageLog> savedLogs, AppPreferences prefs) {
    final sentRefs = savedLogs.where((l) => l.isSent && l.referenceId != null).map((l) => l.referenceId!).toSet();
    final pendingList = <WaMessageLog>[];

    // 1. Booking yang WA-nya belum terkirim
    for (final h in widget.heldOrders) {
      if (h.isWaPending && !sentRefs.contains('booking_${h.id}')) {
        pendingList.add(WaMessageLog(
          id: 'pending_booking_${h.id}',
          recipientName: h.customerName?.trim().isNotEmpty == true ? h.customerName! : 'Pelanggan Booking',
          phone: h.customerPhone ?? '',
          category: 'booking',
          message: WhatsAppReminderService.formatMessage(order: h, storeName: widget.storeName, template: prefs.waBookingTemplate),
          status: 'pending',
          referenceId: 'booking_${h.id}',
          createdAt: h.plannedDate ?? h.heldAt,
        ));
      }
    }

    // 2. Tagihan kasbon aktif yang belum pernah dikirim WA
    final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');
    for (final s in widget.kasbonSales) {
      final refKey = 'kasbon_${s.id}';
      if (!sentRefs.contains(refKey)) {
        CustomerModel? cust;
        if (s.customerId != null) {
          for (final c in widget.customers) {
            if (c.id == s.customerId) {
              cust = c;
              break;
            }
          }
        }
        final custName = s.customerName ?? cust?.name ?? 'Pelanggan Kasbon';
        final msg = AppPreferences.renderTemplate(prefs.waKasbonTemplate, {
          'nama': custName,
          'toko': widget.storeName,
          'no_nota': s.invoiceNumber,
          'tanggal': dateFmt.format(s.createdAt),
          'jatuh_tempo': s.dueDate != null ? dateFmt.format(s.dueDate!) : 'Belum ditentukan',
          'total': CurrencyFormatter.format(s.finalAmount),
        });
        pendingList.add(WaMessageLog(
          id: 'pending_$refKey',
          recipientName: custName,
          phone: cust?.phone ?? '',
          category: 'kasbon',
          message: msg,
          status: 'pending',
          referenceId: refKey,
          createdAt: s.dueDate ?? s.createdAt,
        ));
      }
    }

    return [...pendingList, ...savedLogs];
  }

  @override
  Widget build(BuildContext context) {
    final savedLogs = ref.watch(waHistoryProvider);
    final prefs = ref.watch(appPreferencesProvider);
    final allItems = _buildCombinedList(savedLogs, prefs);

    final pendingCount = allItems.where((e) => e.isPending).length;
    final sentCount = allItems.where((e) => e.isSent).length;
    final failedCount = allItems.where((e) => e.isFailed).length;

    final filtered = allItems.where((item) {
      if (_filter == 'pending' && !item.isPending) return false;
      if (_filter == 'sent' && !item.isSent) return false;
      if (_filter == 'failed' && !item.isFailed) return false;
      if (widget.searchQuery.isNotEmpty) {
        final q = widget.searchQuery;
        return item.recipientName.toLowerCase().contains(q) ||
            item.phone.toLowerCase().contains(q) ||
            item.message.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ReminderFilterChip(label: 'Semua (${allItems.length})', isSelected: _filter == 'semua', onTap: () => setState(() => _filter = 'semua')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Belum ($pendingCount)', isSelected: _filter == 'pending', onTap: () => setState(() => _filter = 'pending')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Terkirim ($sentCount)', isSelected: _filter == 'sent', onTap: () => setState(() => _filter = 'sent')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Gagal ($failedCount)', isSelected: _filter == 'failed', onTap: () => setState(() => _filter = 'failed')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const ReminderEmptyView(
                  title: 'Belum Ada Riwayat WhatsApp',
                  subtitle: 'Pesan WA yang dikirim, gagal, atau belum dikirim akan tercatat di sini.',
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _buildLogCard(ctx, filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildLogCard(BuildContext context, WaMessageLog item) {
    final color = item.isSent
        ? const Color(0xFF059669)
        : (item.isFailed ? AppColors.error : const Color(0xFFD97706));
    final bg = item.isSent
        ? const Color(0xFFECFDF5)
        : (item.isFailed ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB));
    final statusLabel = item.isSent ? 'Terkirim' : (item.isFailed ? 'Gagal' : 'Belum Dikirim');
    final timeStr = DateFormat('d MMM, HH:mm', 'id_ID').format(item.sentAt ?? item.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.recipientName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(5)),
                          child: Text(item.categoryLabel, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.phone.isNotEmpty ? item.phone : "No. WA belum diisi"} • $timeStr',
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
                child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.errorReason != null && item.isFailed ? 'Gagal: ${item.errorReason}' : item.message,
            style: TextStyle(fontSize: 11, color: item.isFailed ? AppColors.error : AppColors.textSecondary, height: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!item.id.startsWith('pending_'))
                TextButton.icon(
                  onPressed: () => ref.read(waHistoryProvider.notifier).deleteLog(item.id),
                  icon: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.textMuted),
                  label: const Text('Hapus', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: () => ReminderMessageDialog.show(
                  context,
                  title: item.isSent ? 'Kirim Ulang Pesan WA' : 'Kirim Pesan WA',
                  recipientName: item.recipientName,
                  initialPhone: item.phone,
                  initialMessage: item.message,
                  category: item.category,
                  referenceId: item.referenceId,
                ),
                icon: const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                label: Text(item.isSent ? 'Kirim Ulang' : 'Kirim WA', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
