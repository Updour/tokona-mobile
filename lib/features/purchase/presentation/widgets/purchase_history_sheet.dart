import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/purchase_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_bottom_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_detail_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_history_card.dart';

class PurchaseHistorySheet extends ConsumerStatefulWidget {
  const PurchaseHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PurchaseHistorySheet(),
    );
  }

  @override
  ConsumerState<PurchaseHistorySheet> createState() => _PurchaseHistorySheetState();
}

class _PurchaseHistorySheetState extends ConsumerState<PurchaseHistorySheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId != null) {
      ref.read(purchaseControllerProvider.notifier).loadPurchases(storeId);
    }
  }

  List<PurchaseModel> _getFilteredPurchases(List<PurchaseModel> list) {
    return list.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.invoiceNumber.toLowerCase().contains(_searchQuery) ||
          (p.supplierName?.toLowerCase().contains(_searchQuery) ?? false);

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Diterima':
          return p.status == 'received';
        case 'PO Berjalan':
          return p.isPreOrder || p.isShipping;
        case 'Online':
          return p.isOnline;
        case 'Dibatalkan':
          return p.isCancelled;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final filteredList = _getFilteredPurchases(purchaseState.purchases);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
        child: Column(
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riwayat Pembelian', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                      Text('${filteredList.length} transaksi belanja stok tercatat', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primary, size: 21),
                  tooltip: 'Catat Belanja Baru',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    Navigator.of(context).pop();
                    AddPurchaseBottomSheet.show(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildFilterChips(),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _loadData(),
                color: AppColors.primary,
                child: purchaseState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            itemCount: filteredList.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final purchase = filteredList[index];
                              return PurchaseHistoryCard(
                                purchase: purchase,
                                onTap: () => PurchaseDetailSheet.show(context, purchase),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari no. faktur atau nama supplier...',
          hintStyle: AppTypography.bodySmall.copyWith(fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Diterima', 'PO Berjalan', 'Online', 'Dibatalkan'];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceInput,
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (_) => setState(() => _selectedFilter = filter),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum Ada Data Pembelian',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Transaksi belanja stok yang dicatat akan muncul di daftar ini.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  AddPurchaseBottomSheet.show(context);
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                label: const Text('Catat Belanja Baru', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

