import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class IncomingOrderCard extends StatelessWidget {
  final PurchaseModel purchase;
  final VoidCallback onConfirmArrival;
  final VoidCallback onCancel;
  final VoidCallback? onMarkShipped;

  const IncomingOrderCard({
    super.key,
    required this.purchase,
    required this.onConfirmArrival,
    required this.onCancel,
    this.onMarkShipped,
  });

  @override
  Widget build(BuildContext context) {
    final p = purchase;
    final isPo = p.isPreOrder;
    final badgeColor = isPo ? const Color(0xFFD97706) : const Color(0xFF0F766E);
    final badgeBg = isPo ? const Color(0xFFFEF3C7) : const Color(0xFFCCFBF1);
    final label = isPo ? 'PO ${p.poDays ?? 3} Hari' : '🚚 Dalam Pengiriman';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          p.invoiceNumber,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                        ),
                        if (p.supplierName != null && p.supplierName!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              p.supplierName!,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                            child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor)),
                          ),
                          if (p.deviceTag != null && p.deviceTag!.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                              child: Text('📱 ${p.deviceTag!}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                            ),
                          ],
                          if (p.platform != null && p.platform!.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(6)),
                              child: Text(p.platform!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6D28D9))),
                            ),
                          ],
                          if (p.paymentAccount != null && p.paymentAccount!.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                              child: Text(p.paymentAccount!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(p.grandTotal),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.items.isNotEmpty ? p.items.map((i) => '${i.quantity.toStringAsFixed(0)} ${i.unitName}').join(', ') : 'Pesanan ${p.invoiceNumber}',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: onCancel,
                tooltip: 'Batalkan Pesanan',
                icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
              if (isPo && onMarkShipped != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMarkShipped,
                    icon: const Icon(Icons.local_shipping_outlined, size: 14),
                    label: const Text('Ada Resi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF0F766E)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: isPo ? 1 : 2,
                child: ElevatedButton.icon(
                  onPressed: onConfirmArrival,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.white),
                  label: Text(
                    isPo ? 'Tiba' : 'Terima Barang',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPo ? const Color(0xFF4338CA) : const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
