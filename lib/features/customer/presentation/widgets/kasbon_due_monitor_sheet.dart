import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
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
  String _activeTab = 'all';

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
                        Text('Jatuh Tempo Kasbon', style: AppTypography.headingSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
                        Text('${kasbonSales.length} tagihan hutang langganan', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScheduledReminderSheet.show(context, initialTab: 1);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded, size: 12, color: Color(0xFF059669)),
                      SizedBox(width: 4),
                      Text('Kirim WA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded, size: 20)),
            ],
          ),
          const SizedBox(height: 12),
          _buildKpiCard(totalKasbonAmount, totalOverdueAmount, overdueSales.length),
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

  Widget _buildKpiCard(double total, double overdue, int overdueCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Piutang Kasbon', style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFB45309))),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFFDE68A)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Lewat Tempo', style: TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                    if (overdueCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                        child: Text('$overdueCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(CurrencyFormatter.format(overdue), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.error)),
              ],
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
