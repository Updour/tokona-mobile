import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class PackagingInfoDialog {
  PackagingInfoDialog._();

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
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primaryDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Satuan Kemasan Bertingkat', style: AppTypography.headingSmall),
                      Text('Panduan Multi-Tier Packaging', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoCard(
              title: 'Apa itu Satuan Bertingkat?',
              desc: 'Fitur untuk menjual satu barang dalam berbagai level kemasan (misal eceran Pcs dan grosir Dus/Karton) tanpa perlu membuat data barang ganda.',
            ),
            const SizedBox(height: 10),
            _infoCard(
              title: 'Otomasi Potong Stok',
              desc: 'Stok inventaris toko selalu dipusatkan di Satuan Dasar. Jika 1 Dus (isi 24 Pcs) terjual di kasir, stok dasar otomatis berkurang 24.',
            ),
            const SizedBox(height: 10),
            _infoCard(
              title: 'Perhitungan HPP & Laba Akurat',
              desc: 'HPP kemasan dihitung otomatis dari HPP satuan dasar dikali isi kemasan, sehingga laporan laba kotor tetap presisi.',
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('MENGERTI'),
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
