import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/purchase/presentation/widgets/shipment_tracking_sheet.dart';

class PurchaseTrackingSection extends StatelessWidget {
  final String rawTracking;
  final VoidCallback? onConfirmArrival;

  const PurchaseTrackingSection({
    super.key,
    required this.rawTracking,
    this.onConfirmArrival,
  });

  @override
  Widget build(BuildContext context) {
    final raw = rawTracking.trim();
    String courier = 'J&T Cargo';
    String waybill = raw;
    final bracket = RegExp(r'^\[([^\]]+)\]\s*(.*)$').firstMatch(raw);
    if (bracket != null) {
      courier = bracket.group(1)?.trim() ?? 'J&T Cargo';
      waybill = bracket.group(2)?.trim() ?? raw;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ekspedisi', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(5)),
                child: Text(courier, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('No. Resi', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
              Row(
                children: [
                  Text(waybill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: waybill));
                      AppToast.showSuccess(context, 'No. resi disalin');
                    },
                    child: const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ShipmentTrackingSheet.show(
                context,
                waybillNo: waybill,
                courier: courier,
                onConfirmArrival: onConfirmArrival,
              ),
              icon: const Icon(Icons.my_location_rounded, size: 14),
              label: const Text('Lacak Posisi Paket Live', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
