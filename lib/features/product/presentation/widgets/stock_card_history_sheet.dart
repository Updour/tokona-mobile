import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/product/data/repositories/stock_repository.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';
import 'package:tokona/features/product/presentation/widgets/stock_adjustment_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/stock_mutation_tile.dart';

class StockCardHistorySheet extends ConsumerStatefulWidget {
  final ProductModel product;

  const StockCardHistorySheet({
    super.key,
    required this.product,
  });

  static Future<void> show(BuildContext context, {required ProductModel product}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockCardHistorySheet(product: product),
    );
  }

  @override
  ConsumerState<StockCardHistorySheet> createState() => _StockCardHistorySheetState();
}

class _StockCardHistorySheetState extends ConsumerState<StockCardHistorySheet> {
  List<StockMutationModel> _mutations = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadMutations();
  }

  Future<void> _loadMutations() async {
    setState(() => _isLoading = true);
    final list = await ref.read(stockRepositoryProvider).getMutationsByProduct(widget.product.id);
    if (mounted) {
      setState(() {
        _mutations = list;
        _isLoading = false;
      });
    }
  }

  List<StockMutationModel> get _filteredList {
    if (_selectedFilter == 'Masuk (+)') {
      return _mutations.where((m) => m.isIn).toList();
    } else if (_selectedFilter == 'Keluar (-)') {
      return _mutations.where((m) => m.isOut).toList();
    }
    return _mutations;
  }

  @override
  Widget build(BuildContext context) {
    final stockStr = widget.product.stockBase % 1 == 0
        ? widget.product.stockBase.toInt().toString()
        : widget.product.stockBase.toStringAsFixed(1);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kartu Riwayat Stok', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(widget.product.name, style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
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
            _buildStockSummaryCard(stockStr),
            const SizedBox(height: 12),
            _buildFilterRow(),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMutations,
                color: AppColors.primary,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              return StockMutationTile(
                                mutation: _filteredList[index],
                                baseUnit: widget.product.baseUnit,
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

  Widget _buildStockSummaryCard(String stockStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 7),
              Text(
                'Stok: $stockStr ${widget.product.baseUnit}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              final result = await StockAdjustmentSheet.show(context, product: widget.product);
              if (result == true) _loadMutations();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 12, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Penyesuaian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['Semua', 'Masuk (+)', 'Keluar (-)'];
    return Row(
      children: filters.map((f) {
        final isSelected = _selectedFilter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(
            label: Text(f),
            selected: isSelected,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelStyle: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceInput,
            side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onSelected: (_) => setState(() => _selectedFilter = f),
          ),
        );
      }).toList(),
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
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(color: AppColors.surfaceInput, shape: BoxShape.circle),
                child: const Icon(Icons.history_toggle_off_rounded, size: 36, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum Ada Mutasi Stok',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Setiap penjualan, pembelian, atau penyesuaian stok akan tercatat otomatis di kartu stok ini.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

