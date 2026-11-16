import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/purchase/domain/models/shipment_tracking_result.dart';

class ShipmentTrackingHeaderCard extends StatelessWidget {
  final ShipmentTrackingResult result;

  const ShipmentTrackingHeaderCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: result.isDelivered ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result.latestStatus.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
              ),
              if (result.serviceType != null)
                Text(
                  result.serviceType!,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Asal Pengiriman', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      result.originCity ?? 'Kota Pengirim',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF16A34A)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Kota Tujuan', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      result.destinationCity ?? 'Kota Toko',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (result.weight != null || result.packageCount != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFDCFCE7)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (result.packageCount != null)
                  Text('Jumlah: ${result.packageCount} Koli / Paket', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
                if (result.weight != null)
                  Text('Berat: ${result.weight} Kg', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

