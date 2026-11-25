import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/purchase/domain/models/purchase_model.dart';

class PurchaseHistoryStatusBadge extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseHistoryStatusBadge({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (purchase.status) {
      case 'received':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        label = purchase.isAutoReceived ? 'Diterima Sistem' : 'Diterima';
        break;
      case 'pre_order':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        label = 'PO Berjalan';
        break;
      case 'shipping':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        label = 'Pengiriman';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        label = 'Dibatalkan';
        break;
      default:
        bg = AppColors.surfaceInput;
        fg = AppColors.textMuted;
        label = purchase.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class PurchaseHistoryChannelBadge extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseHistoryChannelBadge({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final isCo = purchase.isCoOrder;
    final isOnline = purchase.isOnline;
    final isReceived = purchase.status == 'received';

    if (isCo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isReceived ? const Color(0xFFFEF3C7).withValues(alpha: 0.6) : const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.handshake_outlined, size: 12, color: Color(0xFFD97706)),
            const SizedBox(width: 4),
            Text(
              'Co-Order: ${purchase.coPartner ?? "Mitra"}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF92400E),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isReceived
            ? const Color(0xFFF1F5F9)
            : (isOnline ? const Color(0xFFEDE9FE) : AppColors.surfaceInput),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.shopping_bag_outlined : Icons.store_outlined,
            size: 12,
            color: isReceived ? const Color(0xFF94A3B8) : (isOnline ? const Color(0xFF7C3AED) : AppColors.textMuted),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? (purchase.platform ?? 'Online') : 'Toko Fisik',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isReceived ? const Color(0xFF64748B) : (isOnline ? const Color(0xFF6D28D9) : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
