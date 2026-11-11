import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class CustomerPickerEmptyState extends StatelessWidget {
  final String searchQuery;

  const CustomerPickerEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_search_rounded, size: 38, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty ? 'Pelanggan Tidak Ditemukan' : 'Belum Ada Data Pelanggan',
            style: AppTypography.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            searchQuery.isNotEmpty
                ? 'Tidak ada pelanggan bernama "$searchQuery"'
                : 'Tambah pelanggan pertama toko dengan tombol "+ Baru"',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
