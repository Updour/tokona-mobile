import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/purchase/domain/models/shipment_tracking_result.dart';

class ShipmentTimelineTile extends StatelessWidget {
  final TrackingTimelinePoint point;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<String>? onCall;

  const ShipmentTimelineTile({
    super.key,
    required this.point,
    required this.isFirst,
    required this.isLast,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
                    border: isFirst ? Border.all(color: const Color(0xFFBBF7D0), width: 3) : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          point.statusName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isFirst ? FontWeight.w800 : FontWeight.w600,
                            color: isFirst ? const Color(0xFF0F766E) : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        point.scanTime,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
                          color: isFirst ? const Color(0xFF0F766E) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    point.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: isFirst ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  if (point.officerName != null || (point.contactPhone != null && point.contactPhone!.trim().isNotEmpty)) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (point.officerName != null)
                          Text('Petugas: ${point.officerName}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                        if (point.contactPhone != null && point.contactPhone!.trim().isNotEmpty)
                          InkWell(
                            onTap: () => onCall?.call(point.contactPhone!),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_in_talk_rounded, size: 12, color: Color(0xFF16A34A)),
                                  const SizedBox(width: 3),
                                  Text(
                                    point.contactPhone!,
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

