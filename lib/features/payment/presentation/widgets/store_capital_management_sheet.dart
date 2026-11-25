import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/payment/presentation/controllers/store_capital_controller.dart';
import 'package:tokona/features/payment/presentation/widgets/add_store_capital_bottom_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_card.dart';
import 'package:tokona/features/payment/presentation/widgets/store_capital_kpi_card.dart';

class StoreCapitalManagementSheet extends ConsumerStatefulWidget {
  const StoreCapitalManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StoreCapitalManagementSheet(),
    );
  }

  @override
  ConsumerState<StoreCapitalManagementSheet> createState() => _StoreCapitalManagementSheetState();
}

class _StoreCapitalManagementSheetState extends ConsumerState<StoreCapitalManagementSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeId = ref.read(authProvider).currentStore?.id;
      if (storeId != null) {
        ref.read(storeCapitalControllerProvider.notifier).loadCapitals(storeId);
        ref.read(paymentAccountListProvider.notifier).loadAccounts(storeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authProvider).currentStore;
    final state = ref.watch(storeCapitalControllerProvider);
    final notifier = ref.read(storeCapitalControllerProvider.notifier);
    final totalStoreBalance = ref.watch(totalStoreBalanceProvider);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modal Usaha & Tambahan', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                      Text(
                        'Catatan modal awal, suntikan modal & prive',
                        style: AppTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StoreCapitalKpiCard(state: state, totalStoreBalance: totalStoreBalance),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AddStoreCapitalBottomSheet.show(context, initialType: 'TAMBAH_MODAL'),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 15),
                    label: const Text('Tambah Modal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => AddStoreCapitalBottomSheet.show(context, initialType: 'TARIK_MODAL'),
                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 15, color: AppColors.error),
                    label: Text(
                      totalStoreBalance > 0
                          ? 'Tarik Kas (${CurrencyFormatter.format(totalStoreBalance)})'
                          : 'Tarik Kas',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      backgroundColor: const Color(0xFFFEF2F2),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildFilterChips(store?.id, state, notifier),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (store != null) await notifier.loadCapitals(store.id);
                },
                child: state.isLoading && state.capitals.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.capitals.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: state.capitals.length,
                            itemBuilder: (context, index) {
                              final cap = state.capitals[index];
                              return StoreCapitalCard(
                                capital: cap,
                                onDelete: () => notifier.deleteCapital(cap),
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

  Widget _buildFilterChips(String? storeId, dynamic state, dynamic notifier) {
    final types = [
      ('ALL', 'Semua'),
      ('TAMBAH_MODAL', 'Tambahan'),
      ('MODAL_AWAL', 'Modal Awal'),
      ('TARIK_MODAL', 'Tarik Kas'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((t) {
          final isSelected = state.selectedType == t.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(t.$2),
              selected: isSelected,
              onSelected: (val) {
                if (val && storeId != null) notifier.setTypeFilter(t.$1, storeId);
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
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
            Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text('Belum ada catatan modal usaha', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            SizedBox(height: 4),
            Text('Klik tombol Catat untuk memasukkan modal awal atau tambahan modal', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
