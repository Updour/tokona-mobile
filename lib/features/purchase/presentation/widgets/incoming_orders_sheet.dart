import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_order_card.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_filter_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/input_tracking_number_dialog.dart';
import 'package:tokona/features/purchase/presentation/widgets/refund_monitor_sheet.dart';

class IncomingOrdersSheet extends ConsumerStatefulWidget {
  const IncomingOrdersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const IncomingOrdersSheet(),
    );
  }

  @override
  ConsumerState<IncomingOrdersSheet> createState() => _IncomingOrdersSheetState();
}

class _IncomingOrdersSheetState extends ConsumerState<IncomingOrdersSheet> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearchVisible = false;
  String _statusFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final storeId = ref.read(authProvider).currentStore?.id;
    if (storeId == null) return;
    setState(() => _isLoading = true);
    await ref.read(activeOrdersProvider.notifier).loadOrders(storeId);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleConfirmArrival(PurchaseModel p) async {
    final ok = await AppDialog.showConfirmation(
      context,
      title: 'Konfirmasi Barang Tiba',
      message: 'Apakah paket fisik nota ${p.invoiceNumber} sudah tiba? Stok otomatis bertambah.',
      confirmText: 'Ya, Terima Barang',
      icon: Icons.inventory_2_outlined,
    );
    if (ok == true && mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) await ref.read(activeOrdersProvider.notifier).confirmReceived(p.id, sId);
      if (mounted) AppToast.showSuccess(context, 'Stok barang berhasil ditambahkan');
    }
  }

  Future<void> _handleCancel(PurchaseModel p) async {
    final ok = await AppDialog.showConfirmation(
      context,
      title: 'Batalkan Pesanan',
      message: 'Penjual membatalkan pesanan? Dana ${CurrencyFormatter.format(p.grandTotal)} dialihkan ke refund.',
      confirmText: 'Ya, Batalkan',
      isDestructive: true,
      icon: Icons.cancel_outlined,
    );
    if (ok == true && mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) await ref.read(activeOrdersProvider.notifier).cancelOrder(p.id, sId);
      if (mounted) AppToast.showWarning(context, 'Pesanan dibatalkan');
    }
  }

  Future<void> _handleMarkShipped(PurchaseModel p) async {
    final resi = await InputTrackingNumberDialog.show(
      context,
      currentResi: p.trackingNumber,
      invoiceNumber: p.invoiceNumber,
      supplierName: p.supplierName,
    );
    if (resi != null && mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) {
        final tracking = resi.trim().isNotEmpty ? resi.trim() : null;
        await ref.read(activeOrdersProvider.notifier).markAsShipped(p.id, sId, trackingNumber: tracking);
        if (mounted) {
          AppToast.showSuccess(
            context,
            tracking != null ? 'Pesanan dikirim • Resi: $tracking' : 'Status diubah ke Dalam Pengiriman',
          );
        }
      }
    }
  }

  Future<void> _handleEditTracking(PurchaseModel p) async {
    final resi = await InputTrackingNumberDialog.show(
      context,
      currentResi: p.trackingNumber,
      invoiceNumber: p.invoiceNumber,
      supplierName: p.supplierName,
      isUpdateOnly: true,
    );
    if (resi != null && mounted) {
      final sId = ref.read(authProvider).currentStore?.id;
      if (sId != null) {
        await ref.read(activeOrdersProvider.notifier).updateTrackingNumber(p.id, sId, resi.trim());
        if (mounted) AppToast.showSuccess(context, 'No. resi berhasil diperbarui');
      }
    }
  }

  void _showFilterSheet() {
    IncomingOrdersFilterSheet.show(
      context,
      currentFilter: _statusFilter,
      onSelectFilter: (val) => setState(() => _statusFilter = val),
    );
  }

  List<PurchaseModel> _getFilteredOrders(List<PurchaseModel> orders) {
    return orders.where((p) {
      if (_statusFilter == 'PO' && !p.isPreOrder) return false;
      if (_statusFilter == 'SHIPPING' && !p.isShipping) return false;
      if (_searchQuery.isNotEmpty) {
        final matchInv = p.invoiceNumber.toLowerCase().contains(_searchQuery);
        final matchSup = p.supplierName?.toLowerCase().contains(_searchQuery) ?? false;
        final matchItem = p.items.any((i) => (i.productName ?? '').toLowerCase().contains(_searchQuery));
        if (!matchInv && !matchSup && !matchItem) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = ref.watch(activeOrdersProvider);
    final filtered = _getFilteredOrders(activeOrders);

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pesanan Masuk', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
                      Text('${filtered.length} pesanan PO & pengiriman', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isSearchVisible ? Icons.search_off_rounded : Icons.search_rounded, color: _isSearchVisible ? AppColors.primary : AppColors.textPrimary, size: 20),
                  tooltip: 'Cari Pesanan',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => setState(() {
                    _isSearchVisible = !_isSearchVisible;
                    if (!_isSearchVisible) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  }),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
                      tooltip: 'Filter Status',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: _showFilterSheet,
                    ),
                    if (_statusFilter != 'ALL')
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.currency_exchange_rounded, color: Color(0xFFD97706), size: 20),
                  tooltip: 'Refund',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    Navigator.of(context).pop();
                    RefundMonitorSheet.show(context);
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
            if (_isSearchVisible) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.surfaceInput, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: 'Cari no. faktur, nama toko, barang...',
                    hintStyle: TextStyle(fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading && filtered.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (ctx, idx) {
                            final item = filtered[idx];
                            return IncomingOrderCard(
                              purchase: item,
                              onConfirmArrival: () => _handleConfirmArrival(item),
                              onCancel: () => _handleCancel(item),
                              onMarkShipped: item.isPreOrder ? () => _handleMarkShipped(item) : null,
                              onEditTracking: item.isShipping ? () => _handleEditTracking(item) : null,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_rounded, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text('Tidak Ada Pesanan Berjalan', style: AppTypography.labelMedium),
          const SizedBox(height: 2),
          Text('Semua pesanan masuk telah selesai diterima', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
