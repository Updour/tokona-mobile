import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/data/repositories/purchase_repository.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/widgets/purchase_detail_sheet.dart';

class ProductProcurementHistoryTab extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String baseUnit;

  const ProductProcurementHistoryTab({
    super.key,
    required this.productId,
    required this.productName,
    required this.baseUnit,
  });

  @override
  ConsumerState<ProductProcurementHistoryTab> createState() => _ProductProcurementHistoryTabState();
}

class _ProductProcurementHistoryTabState extends ConsumerState<ProductProcurementHistoryTab> {
  List<PurchaseModel> _purchases = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final list = await ref.read(purchaseRepositoryProvider).getPurchasesByProduct(widget.productId);
    if (mounted) setState(() { _purchases = list; _isLoading = false; });
  }

  List<PurchaseModel> get _filteredList {
    if (_selectedFilter == 'PO Aktif') return _purchases.where((p) => p.isPreOrder).toList();
    if (_selectedFilter == 'OTW') return _purchases.where((p) => p.isShipping).toList();
    if (_selectedFilter == 'Diterima') return _purchases.where((p) => p.isReceived).toList();
    if (_selectedFilter == 'Batal/Refund') return _purchases.where((p) => p.isCancelled || p.hasPendingRefund).toList();
    return _purchases;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterRow(),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadHistory,
            color: AppColors.primary,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) => _buildPurchaseCard(_filteredList[index]),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    final filters = ['Semua', 'PO Aktif', 'OTW', 'Diterima', 'Batal/Refund'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
      ),
    );
  }

  Widget _buildPurchaseCard(PurchaseModel p) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final relevantItems = p.items.where((i) => i.productId == widget.productId).toList();
    final totalQtyThisProduct = relevantItems.fold(0.0, (acc, i) => acc + i.quantity);
    final unitName = relevantItems.isNotEmpty ? relevantItems.first.unitName : widget.baseUnit;
    final unitCost = relevantItems.isNotEmpty ? relevantItems.first.unitCost : 0.0;
    final subtotal = relevantItems.isNotEmpty ? relevantItems.first.subtotal : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.isCancelled ? const Color(0xFFEF4444).withValues(alpha: 0.3) : AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await PurchaseDetailSheet.show(context, purchase: p);
            _loadHistory();
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(p),
                    Text(dateFormat.format(p.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(p.isOnline ? Icons.shopping_bag_outlined : Icons.store_mall_directory_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        p.supplierName ?? p.platform ?? 'Supplier',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.deviceTag != null && p.deviceTag!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(4)),
                        child: Text(p.deviceTag!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF3730A3))),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('No. Faktur: ${p.invoiceNumber}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace')),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pesanan: $totalQtyThisProduct $unitName', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                    Text(
                      '${CurrencyFormatter.format(subtotal)} (@ ${CurrencyFormatter.format(unitCost)})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                if (p.isCancelled) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined, size: 12, color: Color(0xFFEF4444)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            p.refundStatus == 'refunded'
                                ? 'Pesanan batal • Dana telah dikembalikan ke saldo'
                                : 'Pesanan batal • Menunggu pengembalian dana (Refund)',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PurchaseModel p) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (p.isCancelled) {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      fg = const Color(0xFFEF4444);
      icon = Icons.cancel_rounded;
      label = 'Batal';
    } else if (p.isPreOrder) {
      bg = const Color(0xFF8B5CF6).withValues(alpha: 0.12);
      fg = const Color(0xFF7C3AED);
      icon = Icons.hourglass_top_rounded;
      label = p.poDays != null ? 'PO ${p.poDays}h' : 'PO';
    } else if (p.isShipping) {
      bg = const Color(0xFF0284C7).withValues(alpha: 0.12);
      fg = const Color(0xFF0284C7);
      icon = Icons.local_shipping_rounded;
      label = 'OTW / Dikirim';
    } else {
      bg = const Color(0xFF10B981).withValues(alpha: 0.12);
      fg = const Color(0xFF059669);
      icon = Icons.check_circle_outline_rounded;
      label = 'Diterima';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          const SizedBox(width: 3.5),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
        ],
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
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(color: AppColors.surfaceInput, shape: BoxShape.circle),
                child: const Icon(Icons.local_shipping_outlined, size: 36, color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              const Text('Belum Ada Riwayat PO / Belanja', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                'Semua pesanan belanja online & PO distributor untuk produk ini akan tercatat riwayat dan statusnya di sini.',
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
