import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/utils/currency_formatter.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class IncomingOrderCard extends StatelessWidget {
  final PurchaseModel purchase;
  final VoidCallback onConfirmArrival;
  final VoidCallback onCancel;
  final VoidCallback? onMarkShipped;
  final VoidCallback? onEditTracking;

  const IncomingOrderCard({
    super.key,
    required this.purchase,
    required this.onConfirmArrival,
    required this.onCancel,
    this.onMarkShipped,
    this.onEditTracking,
  });

  @override
  Widget build(BuildContext context) {
    final p = purchase;
    final isPo = p.isPreOrder;
    final badgeColor = isPo ? const Color(0xFFD97706) : const Color(0xFF0F766E);
    final badgeBg = isPo ? const Color(0xFFFEF3C7) : const Color(0xFFCCFBF1);
    final label = isPo ? 'PO ${p.poDays ?? 3}H' : 'Dalam Kirim';

    final df = DateFormat('dd MMM');
    final hasEstRange = p.estimatedArrival != null;
    final estLabel = hasEstRange
        ? (p.estimatedArrivalEnd != null
            ? '${df.format(p.estimatedArrival!)}–${df.format(p.estimatedArrivalEnd!)}'
            : df.format(p.estimatedArrival!))
        : null;

    final senderName = (p.supplierName != null && p.supplierName!.trim().isNotEmpty)
        ? p.supplierName!.trim()
        : (p.platform ?? 'Supplier Toko');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Pengirim & Total
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.storefront_outlined, size: 15, color: Color(0xFF475569)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            senderName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (p.platform != null && p.platform!.isNotEmpty && p.supplierName != null) ...[
                          const SizedBox(width: 4),
                          Text('(${p.platform})', style: const TextStyle(fontSize: 10, color: Color(0xFF6D28D9), fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      p.invoiceNumber,
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

          // Baris 2: Chips status, device, akun, est
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor)),
                ),
                if (estLabel != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFBBF7D0))),
                    child: Text('Est: $estLabel', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                  ),
                ],
                if (p.deviceTag != null && p.deviceTag!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: Text('📱 ${p.deviceTag!}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                  ),
                ],
                if (p.paymentAccount != null && p.paymentAccount!.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                    child: Text(p.paymentAccount!, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 7),

          // Ringkasan item barang
          Text(
            p.items.isNotEmpty ? p.items.map((i) => '${i.quantity.toStringAsFixed(0)} ${i.unitName} ${i.productName ?? ""}').join(', ') : 'Pesanan ${p.invoiceNumber}',
            style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 7),

          // Strip Resi yang selalu tampil & bisa disalin
          if (p.trackingNumber != null && p.trackingNumber!.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 13, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Resi: ${p.trackingNumber}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534), fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: p.trackingNumber!));
                      AppToast.showSuccess(context, 'No. resi disalin');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 12, color: Color(0xFF15803D)),
                          SizedBox(width: 3),
                          Text('Salin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                        ],
                      ),
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
            ),
          ] else if (onEditTracking != null) ...[
            InkWell(
              onTap: onEditTracking,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 13, color: Color(0xFF0F766E)),
                    SizedBox(width: 5),
                    Text('+ Tambah No. Resi Pengiriman', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F766E))),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: onCancel,
                tooltip: 'Batalkan Pesanan',
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  padding: const EdgeInsets.all(6),
                ),
              ),
              const SizedBox(width: 6),
              if (isPo && onMarkShipped != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMarkShipped,
                    icon: const Icon(Icons.local_shipping_outlined, size: 13),
                    label: const Text('Ada Resi', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF0F766E)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                flex: isPo ? 1 : 2,
                child: ElevatedButton.icon(
                  onPressed: onConfirmArrival,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 13, color: Colors.white),
                  label: Text(
                    isPo ? 'Tiba' : 'Terima Barang',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPo ? const Color(0xFF4338CA) : const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
