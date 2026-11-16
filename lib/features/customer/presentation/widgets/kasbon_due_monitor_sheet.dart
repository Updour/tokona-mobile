import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
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
    final now = DateTime.now();

    final kasbonSales = state.sales.where((s) => s.isKasbon && !s.isVoided).toList();

    final overdueSales = kasbonSales.where((s) {
      if (s.dueDate == null) return false;
      return now.isAfter(s.dueDate!);
    }).toList();

    final dueSoonSales = kasbonSales.where((s) {
      if (s.dueDate == null) return false;
      final diff = s.dueDate!.difference(now).inDays;
      return diff >= 0 && diff <= 7;
    }).toList();

    List<SaleModel> displayedSales;
    if (_activeTab == 'overdue') {
      displayedSales = overdueSales;
    } else if (_activeTab == 'soon') {
      displayedSales = dueSoonSales;
    } else {
      displayedSales = kasbonSales;
    }

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
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jatuh Tempo Kasbon', style: AppTypography.headingSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 1),
                        Text('${displayedSales.length} tagihan hutang aktif', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                      color: _isSearchVisible ? AppColors.primary : AppColors.textPrimary,
                      size: 21,
                    ),
                    tooltip: 'Cari Kasbon',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScheduledReminderSheet.show(context, initialTab: 1);
                    },
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send_rounded, size: 12.5, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text('Kirim WA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              if (_isSearchVisible) ...[
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Cari nama pelanggan, invoice, HP...',
                      hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    ),
                  ),
                ),
              ],
          const SizedBox(height: 12),
          KasbonKpiSummaryCard(
            total: totalKasbonAmount,
            overdue: totalOverdueAmount,
            overdueCount: overdueSales.length,
          ),
          const SizedBox(height: 12),
          _buildFilterTabs(kasbonSales.length, overdueSales.length, dueSoonSales.length),
          const SizedBox(height: 12),
          Expanded(
            child: displayedSales.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: displayedSales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final sale = displayedSales[index];
                      final cust = customers.where((c) => c.id == sale.customerId).firstOrNull;
                      return KasbonSaleTile(sale: sale, customer: cust, now: now);
                    },
                  ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(int total, int overdue, int soon) {
    return Row(
      children: [
        _buildTabPill('all', 'Semua ($total)'),
        const SizedBox(width: 8),
        _buildTabPill('overdue', 'Lewat Tempo ($overdue)', isAlert: overdue > 0),
        const SizedBox(width: 8),
        _buildTabPill('soon', 'H-7 Tempo ($soon)'),
      ],
    );
  }

  Widget _buildTabPill(String key, String label, {bool isAlert = false}) {
    final isSelected = _activeTab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? (isAlert ? AppColors.error : AppColors.primary) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
            SizedBox(height: 10),
            Text('Tidak Ada Kasbon Tertunggak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            SizedBox(height: 4),
            Text('Semua kasbon aman atau sudah lunas', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
