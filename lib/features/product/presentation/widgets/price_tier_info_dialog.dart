import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PriceTierInfoDialog {
  PriceTierInfoDialog._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.price_change_outlined,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga Grosir / Kuantitas', style: AppTypography.headingSmall),
                      Text('Panduan Diskon Pembelian Banyak', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoCard(
              title: 'Bagaimana Cara Kerjanya?',
              desc: 'Harga pembelian 1 unit sudah diatur di Harga Jual Dasar. Kolom grosir ini khusus diskon otomatis jika pelanggan membeli dalam jumlah banyak (misal beli 2 dapat harga lebih murah).',
            ),
            const SizedBox(height: 10),
            _infoCard(
              title: 'Otomatis di Kasir (POS)',
              desc: 'Saat kasir menambah jumlah belanjaan melebihi batas minimal, harga barang langsung berubah otomatis tanpa perlu input diskon manual.',
            ),
            const SizedBox(height: 10),
            _infoCard(
              title: 'Bisa Bertingkat',
              desc: 'Anda bisa membuat beberapa tingkatan (contoh: beli ≥ 2 harga Rp 174.000, beli ≥ 5 harga Rp 173.000).',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('MENGERTI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoCard({required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelMedium.copyWith(fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: AppTypography.bodySmall.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}
