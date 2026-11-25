import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/purchase/presentation/widgets/shipment_tracking_sheet.dart';

class IncomingOrderTrackingTile extends StatelessWidget {
  final String courierName;
  final String waybillCode;
  final VoidCallback onConfirmArrival;
  final VoidCallback? onEditTracking;

  const IncomingOrderTrackingTile({
    super.key,
    required this.courierName,
    required this.waybillCode,
    required this.onConfirmArrival,
    this.onEditTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(4)),
            child: Text(courierName, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              waybillCode,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534), fontFamily: 'monospace'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => ShipmentTrackingSheet.show(
              context,
              waybillNo: waybillCode,
              courier: courierName,
              onConfirmArrival: onConfirmArrival,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text('Lacak', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0284C7))),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              Clipboard.setData(ClipboardData(text: waybillCode));
              AppToast.showSuccess(context, 'No. resi disalin');
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: Text('Salin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
            ),
          ),
          if (onEditTracking != null) ...[
            const SizedBox(width: 4),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onEditTracking,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(Icons.edit_outlined, size: 13, color: Color(0xFF15803D)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
