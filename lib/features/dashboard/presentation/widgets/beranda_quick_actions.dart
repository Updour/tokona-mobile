import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class BerandaQuickActions extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onOpenPurchase;
  final VoidCallback? onQuickScan;
  final VoidCallback? onOpenRefunds;
  final VoidCallback? onOpenIncomingOrders;

  const BerandaQuickActions({
    super.key,
    this.onNavigateTab,
    this.onOpenPurchase,
    this.onQuickScan,
    this.onOpenRefunds,
    this.onOpenIncomingOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat Operasional',
              style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Menu Utama',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernTile(
                title: 'Buka Kasir',
                subtitle: 'Mulai Transaksi',
                icon: Icons.point_of_sale_rounded,
                startColor: const Color(0xFF0D9488),
                endColor: const Color(0xFF14B8A6),
                onTap: () => onNavigateTab?.call(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTile(
                title: 'Master Produk',
                subtitle: 'Multi-Satuan & HPP',
                icon: Icons.inventory_2_rounded,
                startColor: const Color(0xFF4F46E5),
                endColor: const Color(0xFF6366F1),
                onTap: () => onNavigateTab?.call(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernTile(
                title: 'Pembelian Stok',
                subtitle: 'Hitung HPP Otomatis',
                icon: Icons.add_shopping_cart_rounded,
                startColor: const Color(0xFF0284C7),
                endColor: const Color(0xFF38BDF8),
                onTap: () => onOpenPurchase?.call(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTile(
                title: 'Pesanan Berjalan',
                subtitle: 'Pantau PO & Kirim',
                icon: Icons.hourglass_top_rounded,
                startColor: const Color(0xFFD97706),
                endColor: const Color(0xFFFBBF24),
                onTap: () => onOpenIncomingOrders?.call(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernTile(
                title: 'Dana Tertahan',
                subtitle: 'Pantau Refund Akun',
                icon: Icons.account_balance_wallet_outlined,
                startColor: const Color(0xFFE11D48),
                endColor: const Color(0xFFFB7185),
                onTap: () => onOpenRefunds?.call(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernTile(
                title: 'Laporan & Laba',
                subtitle: 'Analitik Keuangan',
                icon: Icons.insights_rounded,
                startColor: const Color(0xFF059669),
                endColor: const Color(0xFF10B981),
                onTap: () => onNavigateTab?.call(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildScanBanner(),
      ],
    );
  }

  Widget _buildModernTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: startColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanBanner() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onQuickScan?.call();
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF065F46)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF065F46).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF34D399),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pindai Cek Cepat Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arahkan kamera untuk cek stok & harga instan',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white70,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
