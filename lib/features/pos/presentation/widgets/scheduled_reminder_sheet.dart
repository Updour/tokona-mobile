import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/add_scheduled_reminder_dialog.dart';
import 'package:tokona/features/pos/presentation/widgets/reminder_tab_helpers.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_backup_tab.dart';
import 'package:tokona/features/pos/presentation/widgets/wa_history_tab_view.dart';

class ScheduledReminderSheet extends ConsumerStatefulWidget {
  final int initialTab;

  const ScheduledReminderSheet({super.key, this.initialTab = 0});

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => ScheduledReminderSheet(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<ScheduledReminderSheet> createState() => _ScheduledReminderSheetState();
}

class _ScheduledReminderSheetState extends ConsumerState<ScheduledReminderSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab.clamp(0, 3));
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(customerListProvider.notifier).loadCustomers(storeId);
        ref.read(saleHistoryControllerProvider.notifier).loadSales(storeId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final storeName = store?.name ?? 'Tokona Store';
    final heldOrders = ref.watch(heldCartProvider);
    final sales = ref.watch(saleHistoryControllerProvider).sales;
    final customers = ref.watch(customerListProvider).customers;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final kasbonSales = sales.where((s) => s.isKasbon && !s.isVoided).toList();
    final totalCount = heldOrders.length + kasbonSales.length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Jadwal & Pengingat',
                            style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$totalCount',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => AddScheduledReminderDialog.show(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 2),
                          Text('Tambah', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 19),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(11),
                ),
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFF0F172A),
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Ambil (${heldOrders.length})'),
                    Tab(text: 'Kasbon (${kasbonSales.length})'),
                    const Tab(text: 'Riwayat WA'),
                    const Tab(text: 'Backup'),
                  ],
                ),
              ),
              if (_tabController.index != 3) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari pelanggan atau nomor nota...',
                    hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, size: 17, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 15, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ReminderBookingTabView(
                      allOrders: heldOrders,
                      storeName: storeName,
                      today: today,
                      searchQuery: _searchQuery,
                      onOrderRestored: () => Navigator.of(context).pop(),
                    ),
                    ReminderKasbonTabView(
                      allSales: kasbonSales,
                      customers: customers,
                      storeName: storeName,
                      now: now,
                      searchQuery: _searchQuery,
                    ),
                    WaHistoryTabView(
                      heldOrders: heldOrders,
                      kasbonSales: kasbonSales,
                      customers: customers,
                      storeName: storeName,
                      searchQuery: _searchQuery,
                    ),
                    const ScheduledBackupTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
