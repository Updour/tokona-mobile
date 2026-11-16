import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/purchase/data/services/shipment_tracking_service.dart';
import 'package:tokona/features/purchase/domain/models/shipment_tracking_result.dart';
import 'package:tokona/features/purchase/presentation/widgets/shipment_timeline_tile.dart';
import 'package:tokona/features/purchase/presentation/widgets/shipment_tracking_header_card.dart';

class ShipmentTrackingSheet extends StatefulWidget {
  final String waybillNo;
  final String courier;
  final String? phoneSuffix;
  final VoidCallback? onConfirmArrival;

  const ShipmentTrackingSheet({
    super.key,
    required this.waybillNo,
    this.courier = 'J&T Cargo',
    this.phoneSuffix,
    this.onConfirmArrival,
  });

  static Future<void> show(
    BuildContext context, {
    required String waybillNo,
    String courier = 'J&T Cargo',
    String? phoneSuffix,
    VoidCallback? onConfirmArrival,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShipmentTrackingSheet(
        waybillNo: waybillNo,
        courier: courier,
        phoneSuffix: phoneSuffix,
        onConfirmArrival: onConfirmArrival,
      ),
    );
  }

  @override
  State<ShipmentTrackingSheet> createState() => _ShipmentTrackingSheetState();
}

class _ShipmentTrackingSheetState extends State<ShipmentTrackingSheet> {
  bool _isLoading = true;
  ShipmentTrackingResult? _result;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
  }

  Future<void> _fetchTracking({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final res = await ShipmentTrackingService.trackWaybill(
      waybillNo: widget.waybillNo,
      courier: widget.courier,
      phoneSuffix: widget.phoneSuffix,
      forceRefresh: forceRefresh,
    );
    if (mounted) {
      setState(() {
        _result = res;
        _isLoading = false;
      });
    }
  }

  Future<void> _makeCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) AppToast.showError(context, 'Tidak dapat membuka panggilan telepon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          widget.courier,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'No. Resi: ${widget.waybillNo}',
                          style: AppTypography.headingSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 22),
                  tooltip: 'Perbarui Status',
                  onPressed: () => _fetchTracking(forceRefresh: true),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : (_result == null || !_result!.isSuccess)
                      ? _buildErrorView()
                      : _buildTrackingContent(_result!),
            ),
            if (_result != null && _result!.isDelivered && widget.onConfirmArrival != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onConfirmArrival?.call();
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Barang Sudah Tiba? Tambah ke Stok Toko', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFFF59E0B)),
            const SizedBox(height: 12),
            Text(
              _result?.errorMessage ?? 'Data tracking belum tersedia di server kurir',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchTracking(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingContent(ShipmentTrackingResult res) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ShipmentTrackingHeaderCard(result: res),
        const SizedBox(height: 18),
        Text(
          'RIWAYAT PERJALANAN PAKET (${res.timeline.length})',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.6),
        ),
        const SizedBox(height: 12),
        ...res.timeline.asMap().entries.map((entry) {
          return ShipmentTimelineTile(
            point: entry.value,
            isFirst: entry.key == 0,
            isLast: entry.key == res.timeline.length - 1,
            onCall: _makeCall,
          );
        }),
      ],
    );
  }
}
