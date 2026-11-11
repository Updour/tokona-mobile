import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/widgets/refund_item_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/refund_summary_banner.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class RefundMonitorSheet extends ConsumerStatefulWidget {
  const RefundMonitorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RefundMonitorSheet(),
    );
  }

  @override
  ConsumerState<RefundMonitorSheet> createState() => _RefundMonitorSheetState();
}

class _RefundMonitorSheetState extends ConsumerState<RefundMonitorSheet> {
  int _selectedTab = 0;
  List<PurchaseModel> _pendingRefunds = [];
  List<PurchaseModel> _completedRefunds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRefunds();
  }

  Future<void> _loadRefunds() async {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId == null) return;

    setState(() => _isLoading = true);
    final repo = ref.read(purchaseRepositoryProvider);
    final results = await Future.wait([
      repo.getPendingRefunds(storeId),
      repo.getCompletedRefunds(storeId),
    ]);

    if (mounted) {
      setState(() {
        _pendingRefunds = results[0];
        _completedRefunds = results[1];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConfirmRefund(PurchaseModel purchase) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Tandai Dana Sudah Masuk',
      message:
          'Apakah dana sebesar ${CurrencyFormatter.format(purchase.grandTotal)} dari ${purchase.deviceTag ?? "HP"} sudah berhasil ditarik ke ${purchase.paymentAccount ?? "rekening toko"}?',
      confirmText: 'Ya, Sudah Masuk',
      icon: Icons.account_balance_wallet_outlined,
    );
    if (confirmed == true && mounted) {
      final storeId = ref.read(authProvider).currentStore?.id;
      await ref.read(purchaseRepositoryProvider).markRefunded(purchase.id);
      if (!mounted) return;
      if (storeId != null) {
        await ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
        ref.read(reportControllerProvider.notifier).loadReport(storeId);
      }
      AppToast.showSuccess(context, 'Dana berhasil ditarik dan saldo rekening bertambah');
      _loadRefunds();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPending = _pendingRefunds.fold<double>(0.0, (acc, p) => acc + p.grandTotal);
    final totalCompleted = _completedRefunds.fold<double>(0.0, (acc, p) => acc + p.grandTotal);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildHeader(),
          const SizedBox(height: 14),
          _buildTabSelector(),
          const SizedBox(height: 12),
          if (_selectedTab == 0)
            RefundSummaryBanner(
              title: 'Total Saldo Tertahan Seluruh HP:',
              amount: totalPending,
              countLabel: '${_pendingRefunds.length} Pesanan',
              isError: true,
            )
          else
            RefundSummaryBanner(
              title: 'Total Dana Masuk ke Rekening Toko:',
              amount: totalCompleted,
              countLabel: '${_completedRefunds.length} Diterima',
              isError: false,
            ),
          const SizedBox(height: 14),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                    ? _buildPendingList()
                    : _buildCompletedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.wallet_outlined, color: AppColors.error, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dana Tertahan (Refund)', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('Pantau saldo pengembalian marketplace per HP belanja', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Tertahan di HP (${_pendingRefunds.length})',
              index: 0,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabButton(
              label: 'Riwayat Masuk (${_completedRefunds.length})',
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String label, required int index}) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pendingRefunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 44, color: AppColors.success),
            const SizedBox(height: 10),
            Text('Tidak Ada Dana Tertahan', style: AppTypography.labelMedium),
            const SizedBox(height: 2),
            Text('Semua dana pengembalian marketplace sudah masuk ke rekening toko', style: AppTypography.bodySmall),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _pendingRefunds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) => RefundItemCard(
        purchase: _pendingRefunds[idx],
        onConfirmRefund: () => _handleConfirmRefund(_pendingRefunds[idx]),
      ),
    );
  }

  Widget _buildCompletedList() {
    if (_completedRefunds.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text('Belum Ada Riwayat Dana Masuk', style: AppTypography.labelMedium),
            const SizedBox(height: 2),
            Text('Dana refund yang sudah ditandai masuk rekening akan tersimpan di sini', style: AppTypography.bodySmall),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _completedRefunds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, idx) => RefundItemCard(
        purchase: _completedRefunds[idx],
        isCompleted: true,
      ),
    );
  }
}
