import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/pos/domain/models/sale_history_state.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/sale_detail_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sale_history_card.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_filter_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_kpi_card.dart';

class SalesHistorySheet extends ConsumerStatefulWidget {
  const SalesHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SalesHistorySheet(),
    );
  }

  @override
  ConsumerState<SalesHistorySheet> createState() => _SalesHistorySheetState();
}

class _SalesHistorySheetState extends ConsumerState<SalesHistorySheet> {
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(saleHistoryControllerProvider.notifier).loadSales(storeId);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDates(String storeId) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && mounted) {
      ref.read(saleHistoryControllerProvider.notifier).setDateFilter(
            SaleDateFilter.custom,
            storeId,
            customStart: picked.start,
            customEnd: picked.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final state = ref.watch(saleHistoryControllerProvider);
    final notifier = ref.read(saleHistoryControllerProvider.notifier);
    final hasActiveFilter = state.dateFilter != SaleDateFilter.today || state.paymentMethodFilter != 'ALL';

    ref.listen(saleHistoryControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        AppToast.showError(context, next.errorMessage!);
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        AppToast.showSuccess(context, next.successMessage!);
      }
    });

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
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
                      Text('Riwayat Penjualan', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        '${state.sales.length} nota transaksi tercatat',
                        style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded,
                        color: _isSearchVisible ? AppColors.primary : AppColors.textPrimary,
                        size: 21,
                      ),
                      tooltip: 'Cari Nota',
                      onPressed: () {
                        setState(() {
                          _isSearchVisible = !_isSearchVisible;
                          if (!_isSearchVisible && _searchController.text.isNotEmpty) {
                            _searchController.clear();
                            if (store?.id != null) notifier.setSearchQuery('', store!.id);
                          }
                        });
                      },
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
                          tooltip: 'Filter Tanggal & Cara Bayar',
                          onPressed: () {
                            SalesHistoryFilterSheet.show(
                              context,
                              state: state,
                              onDateFilterChanged: (f) {
                                if (store != null) notifier.setDateFilter(f, store.id);
                              },
                              onPickCustomDates: () {
                                if (store != null) _pickCustomDates(store.id);
                              },
                              onPaymentMethodChanged: (m) {
                                if (store != null) notifier.setPaymentMethodFilter(m, store.id);
                              },
                              onResetFilter: () {
                                if (store != null) {
                                  notifier.setDateFilter(SaleDateFilter.today, store.id);
                                  notifier.setPaymentMethodFilter('ALL', store.id);
                                }
                              },
                            );
                          },
                        ),
                        if (hasActiveFilter)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            if (_isSearchVisible) ...[
              const SizedBox(height: 10),
              _buildSearchBar(store?.id, notifier),
            ],
            const SizedBox(height: 10),
            SalesHistoryKpiCard(state: state),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (store != null) await notifier.loadSales(store.id);
                },
                child: state.isLoading && state.sales.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.sales.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: state.sales.length,
                            itemBuilder: (context, index) {
                              final sale = state.sales[index];
                              return SaleHistoryCard(
                                sale: sale,
                                onTap: () => SaleDetailSheet.show(context, sale),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(String? storeId, SaleHistoryController notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (val) {
                if (storeId != null) notifier.setSearchQuery(val, storeId);
              },
              decoration: const InputDecoration(
                hintText: 'Cari nomor nota atau nama pelanggan...',
                hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                if (storeId != null) notifier.setSearchQuery('', storeId);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text('Belum ada transaksi penjualan yang cocok', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            SizedBox(height: 4),
            Text('Ubah kata kunci pencarian atau filter di kanan atas', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
