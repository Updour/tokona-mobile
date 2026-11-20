import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_kpi_summary_card.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_sale_tile.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_reminder_sheet.dart';

class KasbonDueMonitorSheet extends ConsumerStatefulWidget {
  const KasbonDueMonitorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const KasbonDueMonitorSheet(),
    );
  }

  @override
  ConsumerState<KasbonDueMonitorSheet> createState() => _KasbonDueMonitorSheetState();
}

class _KasbonDueMonitorSheetState extends ConsumerState<KasbonDueMonitorSheet> {
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _searchQuery = '';
  String _activeTab = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(saleHistoryControllerProvider.notifier).loadSales(storeId);
        ref.read(customerListProvider.notifier).loadCustomers(storeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(saleHistoryControllerProvider);
    final customers = ref.watch(customerListProvider).customers;
    final storeName = ref.watch(authProvider).currentStore?.name;
    final now = DateTime.now();

    final kasbonSales = state.sales.where((s) => s.isKasbon && !s.isVoided).toList();
    final overdueSales = kasbonSales.where((s) => s.dueDate != null && now.isAfter(s.dueDate!)).toList();
    final dueSoonSales = kasbonSales.where((s) => s.dueDate != null && s.dueDate!.difference(now).inDays >= 0 && s.dueDate!.difference(now).inDays <= 7).toList();

    List<SaleModel> displayedSales = _activeTab == 'overdue' ? overdueSales : _activeTab == 'soon' ? dueSoonSales : kasbonSales;

    if (_searchQuery.isNotEmpty) {
      displayedSales = displayedSales.where((s) {
        final cust = customers.where((c) => c.id == s.customerId).firstOrNull;
        final name = cust?.name.toLowerCase() ?? '';
        final inv = s.invoiceNumber.toLowerCase();
        final phone = cust?.phone?.toLowerCase() ?? '';
        return name.contains(_searchQuery) || inv.contains(_searchQuery) || phone.contains(_searchQuery);
      }).toList();
    }

    final totalKasbonAmount = kasbonSales.fold(0.0, (acc, s) => acc + s.finalAmount);
    final totalOverdueAmount = overdueSales.fold(0.0, (acc, s) => acc + s.finalAmount);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(color: Color(0x140F172A), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 14),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
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
                  children: [
                    Flexible(
                      child: Text(
                        'Jatuh Tempo Kasbon',
                        style: AppTypography.headingSmall.copyWith(fontSize: 14.5, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                      child: Text('${displayedSales.length}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                  color: _isSearchVisible ? AppColors.primary : const Color(0xFF64748B),
                  size: 19,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Cari',
                onPressed: () {
                  setState(() {
                    _isSearchVisible = !_isSearchVisible;
                    if (!_isSearchVisible && _searchQuery.isNotEmpty) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScheduledReminderSheet.show(context, initialTab: 1);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded, size: 11, color: Color(0xFF059669)),
                      SizedBox(width: 3),
                      Text('WA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 19),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          if (_isSearchVisible) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari nama pelanggan, nota, HP...',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 15, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          KasbonKpiSummaryCard(
            total: totalKasbonAmount,
            overdue: totalOverdueAmount,
            overdueCount: overdueSales.length,
          ),
          const SizedBox(height: 8),
          _buildFilterTabs(kasbonSales.length, overdueSales.length, dueSoonSales.length),
          const SizedBox(height: 8),
          Expanded(
            child: displayedSales.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayedSales.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final sale = displayedSales[index];
                      final cust = customers.where((c) => c.id == sale.customerId).firstOrNull;
                      return KasbonSaleTile(sale: sale, customer: cust, now: now, storeName: storeName);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(int total, int overdue, int soon) {
    return Row(
      children: [
        _buildTabPill('all', 'Semua ($total)'),
        const SizedBox(width: 6),
        _buildTabPill('overdue', 'Lewat ($overdue)', isAlert: overdue > 0),
        const SizedBox(width: 6),
        _buildTabPill('soon', 'H-7 ($soon)'),
      ],
    );
  }

  Widget _buildTabPill(String key, String label, {bool isAlert = false}) {
    final isSelected = _activeTab == key;
    return Expanded(
      child: Material(
        color: isSelected
            ? (isAlert ? const Color(0xFFDC2626) : AppColors.primary)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: () => setState(() => _activeTab = key),
          borderRadius: BorderRadius.circular(9),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6.5),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 40, color: Color(0xFF16A34A)),
            SizedBox(height: 8),
            Text('Tidak Ada Kasbon Tertunggak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            SizedBox(height: 2),
            Text('Semua kasbon aman atau sudah lunas', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}
