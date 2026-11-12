import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class ReportMinimalHeader extends StatelessWidget {
  final String activeFilterLabel;
  final bool isFilterActive;
  final bool isLoading;
  final bool isSearching;
  final TextEditingController searchController;
  final ValueChanged<bool> onSearchToggled;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;
  final VoidCallback onRefresh;
  final VoidCallback onOpenReportTypes;
  final VoidCallback? onOpenExport;

  const ReportMinimalHeader({
    super.key,
    required this.activeFilterLabel,
    required this.isFilterActive,
    required this.isLoading,
    required this.isSearching,
    required this.searchController,
    required this.onSearchToggled,
    required this.onSearchChanged,
    required this.onOpenFilter,
    required this.onRefresh,
    required this.onOpenReportTypes,
    this.onOpenExport,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                onChanged: onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Cari produk terlaris / analisis...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.normal),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            if (searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  searchController.clear();
                  onSearchChanged('');
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Color(0xFFE2E8F0), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 13, color: AppColors.textSecondary),
                ),
              ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                searchController.clear();
                onSearchToggled(false);
                onSearchChanged('');
              },
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'Batal',
                  style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Laporan & Analisis', style: AppTypography.headingSmall.copyWith(fontSize: 16)),
              const SizedBox(height: 1),
              InkWell(
                onTap: onOpenFilter,
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.date_range_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        activeFilterLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildActionPill(
          icon: Icons.search_rounded,
          color: AppColors.textPrimary,
          tooltip: 'Cari Produk / Analisis',
          onTap: () => onSearchToggled(true),
        ),
        const SizedBox(width: 6),
        _buildActionPill(
          icon: Icons.refresh_rounded,
          color: const Color(0xFF0284C7),
          tooltip: 'Segarkan Data',
          isLoading: isLoading,
          onTap: isLoading ? () {} : onRefresh,
        ),
        const SizedBox(width: 6),
        Stack(
          alignment: Alignment.center,
          children: [
            _buildActionPill(
              icon: Icons.tune_rounded,
              color: isFilterActive ? const Color(0xFFD97706) : const Color(0xFF64748B),
              tooltip: 'Filter Periode & Rentang Tanggal',
              onTap: onOpenFilter,
            ),
            if (isFilterActive)
              Positioned(
                top: 3,
                right: 3,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD97706),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 6),
        _buildActionPill(
          icon: Icons.grid_view_rounded,
          color: const Color(0xFF4F46E5),
          tooltip: 'Semua Jenis Laporan Toko',
          onTap: onOpenReportTypes,
        ),
        if (onOpenExport != null) ...[
          const SizedBox(width: 6),
          _buildActionPill(
            icon: Icons.table_chart_rounded,
            color: const Color(0xFF059669),
            tooltip: 'Ekspor Excel & WhatsApp',
            onTap: onOpenExport!,
          ),
        ],
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, color: color, size: 19),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
