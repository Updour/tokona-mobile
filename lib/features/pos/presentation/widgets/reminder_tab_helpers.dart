import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/widgets/add_scheduled_reminder_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_booking_tile.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_invoice_tile.dart';

class ReminderFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ReminderFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class ReminderEmptyView extends StatelessWidget {
  final String title;
  final String subtitle;

  const ReminderEmptyView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.textMuted.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ReminderBookingTabView extends StatefulWidget {
  final List<HeldCartModel> allOrders;
  final String storeName;
  final DateTime today;
  final String searchQuery;
  final VoidCallback onOrderRestored;

  const ReminderBookingTabView({
    super.key,
    required this.allOrders,
    required this.storeName,
    required this.today,
    required this.searchQuery,
    required this.onOrderRestored,
  });

  @override
  State<ReminderBookingTabView> createState() => _ReminderBookingTabViewState();
}

class _ReminderBookingTabViewState extends State<ReminderBookingTabView> {
  String _bookingFilter = 'all';

  @override
  Widget build(BuildContext context) {
    var filtered = widget.allOrders;
    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((o) => (o.customerName ?? '').toLowerCase().contains(widget.searchQuery)).toList();
    }
    if (_bookingFilter == 'today') {
      filtered = filtered.where((o) {
        if (o.plannedDate == null) return false;
        final d = DateTime(o.plannedDate!.year, o.plannedDate!.month, o.plannedDate!.day);
        return d.isAtSameMomentAs(widget.today);
      }).toList();
    } else if (_bookingFilter == 'pending') {
      filtered = filtered.where((o) => o.isWaPending).toList();
    } else if (_bookingFilter == 'sent') {
      filtered = filtered.where((o) => o.isWaSent).toList();
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ReminderFilterChip(label: 'Semua (${widget.allOrders.length})', isSelected: _bookingFilter == 'all', onTap: () => setState(() => _bookingFilter = 'all')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Hari Ini', isSelected: _bookingFilter == 'today', onTap: () => setState(() => _bookingFilter = 'today')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Menunggu WA', isSelected: _bookingFilter == 'pending', onTap: () => setState(() => _bookingFilter = 'pending')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Terkirim', isSelected: _bookingFilter == 'sent', onTap: () => setState(() => _bookingFilter = 'sent')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ReminderEmptyView(
                        title: 'Tidak ada jadwal pesanan ambil',
                        subtitle: 'Catat pesanan booking pelanggan untuk dijadwalkan',
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => AddScheduledReminderDialog.show(context),
                        icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        label: const Text('Buat Jadwal Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => ReminderBookingTile(
                    order: filtered[i],
                    storeName: widget.storeName,
                    onOrderRestored: widget.onOrderRestored,
                  ),
                ),
        ),
      ],
    );
  }
}

class ReminderKasbonTabView extends StatefulWidget {
  final List<SaleModel> allSales;
  final List<CustomerModel> customers;
  final String storeName;
  final DateTime now;
  final String searchQuery;

  const ReminderKasbonTabView({
    super.key,
    required this.allSales,
    required this.customers,
    required this.storeName,
    required this.now,
    required this.searchQuery,
  });

  @override
  State<ReminderKasbonTabView> createState() => _ReminderKasbonTabViewState();
}

class _ReminderKasbonTabViewState extends State<ReminderKasbonTabView> {
  String _kasbonFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final today = DateTime(widget.now.year, widget.now.month, widget.now.day);

    var filtered = widget.allSales;
    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((s) {
        final name = (s.customerName ?? '').toLowerCase();
        final no = s.invoiceNumber.toLowerCase();
        return name.contains(widget.searchQuery) || no.contains(widget.searchQuery);
      }).toList();
    }
    if (_kasbonFilter == 'overdue') {
      filtered = filtered.where((s) {
        if (s.dueDate == null) return false;
        final d = DateTime(s.dueDate!.year, s.dueDate!.month, s.dueDate!.day);
        return d.isBefore(today);
      }).toList();
    } else if (_kasbonFilter == 'due_soon') {
      filtered = filtered.where((s) {
        if (s.dueDate == null) return false;
        final d = DateTime(s.dueDate!.year, s.dueDate!.month, s.dueDate!.day);
        final diff = d.difference(today).inDays;
        return diff >= 0 && diff <= 3;
      }).toList();
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ReminderFilterChip(label: 'Semua (${widget.allSales.length})', isSelected: _kasbonFilter == 'all', onTap: () => setState(() => _kasbonFilter = 'all')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Lewat Jatuh Tempo', isSelected: _kasbonFilter == 'overdue', onTap: () => setState(() => _kasbonFilter = 'overdue')),
              const SizedBox(width: 6),
              ReminderFilterChip(label: 'Mendekati Tempo (≤3 Hari)', isSelected: _kasbonFilter == 'due_soon', onTap: () => setState(() => _kasbonFilter = 'due_soon')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const ReminderEmptyView(
                  title: 'Tidak ada tagihan kasbon',
                  subtitle: 'Semua pelanggan telah melunasi atau belum ada kasbon jatuh tempo',
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final sale = filtered[i];
                    final customer = widget.customers.firstWhere(
                      (c) => c.id == sale.customerId,
                      orElse: () => CustomerModel(
                        id: sale.customerId ?? '',
                        storeId: sale.storeId,
                        name: sale.customerName ?? 'Pelanggan',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    return ReminderInvoiceTile(
                      sale: sale,
                      customer: customer,
                      storeName: widget.storeName,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
