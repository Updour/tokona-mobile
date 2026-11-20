import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/settings/data/services/audit_log_service.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';

class AuditLogSheet extends ConsumerStatefulWidget {
  const AuditLogSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuditLogSheet(),
    );
  }

  @override
  ConsumerState<AuditLogSheet> createState() => _AuditLogSheetState();
}

class _AuditLogSheetState extends ConsumerState<AuditLogSheet> {
  AuditActionType? _selectedFilter;
  List<AuditLogModel> _logs = [];
  bool _isLoading = true;
  bool _isSyncingCloud = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _autoSyncCloud();
  }

  Future<void> _loadLogs() async {
    final logs = await AuditLogService.getLogs(filterType: _selectedFilter);
    if (mounted) setState(() { _logs = logs; _isLoading = false; });
  }

  Future<void> _autoSyncCloud() async {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId == null) return;
    setState(() => _isSyncingCloud = true);
    final count = await AuditLogService.syncCloudLogs(storeId);
    if (mounted) {
      setState(() => _isSyncingCloud = false);
      if (count > 0) {
        _loadLogs();
        AppToast.showSuccess(context, '$count log baru ditarik dari Cloud');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(saleHistoryControllerProvider);
    final now = DateTime.now();
    final todaySales = salesState.sales.where((s) => !s.isVoided && s.createdAt.year == now.year && s.createdAt.month == now.month && s.createdAt.day == now.day).toList();
    final todayOmset = todaySales.fold<double>(0, (sum, s) => sum + s.finalAmount);
    final lastLog = _logs.isNotEmpty ? _logs.first : null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.history_toggle_off_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Log Aktivitas & Audit Kasir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('Sinkron langsung dengan Cloud Supabase', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (_isSyncingCloud)
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              else
                IconButton(
                  icon: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 22),
                  tooltip: 'Tarik Log Cloud',
                  onPressed: _autoSyncCloud,
                ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          _buildLiveSummaryCard(todaySales.length, todayOmset, lastLog),
          const SizedBox(height: 10),
          _buildFilterChips(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: _logs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _buildLogItem(_logs[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSummaryCard(int trxCount, double omset, AuditLogModel? lastLog) {
    final lastTime = lastLog != null ? DateFormat('HH:mm').format(lastLog.timestamp) : '-';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Transaksi Kasir Hari Ini', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                Text('$trxCount Trx (${CurrencyFormatter.format(omset)})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F766E))),
              ],
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                Text(lastLog != null ? '$lastTime • ${lastLog.userName}' : 'Belum ada log', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.cloud_done_outlined, size: 32, color: Color(0xFF64748B))),
            const SizedBox(height: 10),
            const Text('Belum Ada Aktivitas Kasir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Log riil otomatis masuk saat kasir login, melayani transaksi POS, atau restok.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip('Semua', _selectedFilter == null, () => _applyFilter(null)),
          const SizedBox(width: 6),
          _buildChip('Transaksi', _selectedFilter == AuditActionType.transaction, () => _applyFilter(AuditActionType.transaction)),
          const SizedBox(width: 6),
          _buildChip('Restok', _selectedFilter == AuditActionType.inventory, () => _applyFilter(AuditActionType.inventory)),
          const SizedBox(width: 6),
          _buildChip('Login', _selectedFilter == AuditActionType.auth, () => _applyFilter(AuditActionType.auth)),
          const SizedBox(width: 6),
          _buildChip('Pairing', _selectedFilter == AuditActionType.pairing, () => _applyFilter(AuditActionType.pairing)),
          const SizedBox(width: 6),
          _buildChip('Shift', _selectedFilter == AuditActionType.shift, () => _applyFilter(AuditActionType.shift)),
          const SizedBox(width: 6),
          _buildChip('RBAC', _selectedFilter == AuditActionType.rbac, () => _applyFilter(AuditActionType.rbac)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF475569))),
      ),
    );
  }

  void _applyFilter(AuditActionType? type) {
    setState(() => _selectedFilter = type);
    _loadLogs();
  }

  Widget _buildLogItem(AuditLogModel log) {
    final (icon, color, bgColor) = _resolveStyle(log.actionType);
    final timeStr = DateFormat('HH:mm • dd MMM', 'id_ID').format(log.timestamp);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(log.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary)),
                    ),
                    Text(timeStr, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(log.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        '${log.userName} (${log.userRole})',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                      ),
                    ),
                    if (log.deviceTag != null) ...[
                      const SizedBox(width: 5),
                      Text('• ${log.deviceTag}', style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, Color) _resolveStyle(AuditActionType type) {
    switch (type) {
      case AuditActionType.pairing: return (Icons.qr_code_scanner_rounded, const Color(0xFF0F766E), const Color(0xFFCCFBF1));
      case AuditActionType.auth: return (Icons.lock_outline_rounded, const Color(0xFF2563EB), const Color(0xFFDBEAFE));
      case AuditActionType.transaction: return (Icons.receipt_long_rounded, const Color(0xFF16A34A), const Color(0xFFDCFCE7));
      case AuditActionType.shift: return (Icons.storefront_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7));
      case AuditActionType.rbac: return (Icons.shield_outlined, const Color(0xFF7C3AED), const Color(0xFFEDE9FE));
      case AuditActionType.inventory: return (Icons.inventory_2_outlined, const Color(0xFF0284C7), const Color(0xFFE0F2FE));
      case AuditActionType.product: return (Icons.shopping_bag_outlined, const Color(0xFF0F766E), const Color(0xFFCCFBF1));
      case AuditActionType.purchase: return (Icons.local_shipping_outlined, const Color(0xFF7C3AED), const Color(0xFFEDE9FE));
      case AuditActionType.finance: return (Icons.account_balance_wallet_outlined, const Color(0xFF059669), const Color(0xFFD1FAE5));
      case AuditActionType.security: return (Icons.fingerprint_rounded, const Color(0xFFDC2626), const Color(0xFFFEE2E2));
    }
  }
}
