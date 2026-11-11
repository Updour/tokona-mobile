import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';

class ProfilePhotoPickerSheet extends StatelessWidget {
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback? onRemovePhoto;
  final bool hasExistingPhoto;

  const ProfilePhotoPickerSheet({
    super.key,
    required this.onPickGallery,
    required this.onPickCamera,
    this.onRemovePhoto,
    this.hasExistingPhoto = false,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPickGallery,
    required VoidCallback onPickCamera,
    VoidCallback? onRemovePhoto,
    bool hasExistingPhoto = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => ProfilePhotoPickerSheet(
        onPickGallery: onPickGallery,
        onPickCamera: onPickCamera,
        onRemovePhoto: onRemovePhoto,
        hasExistingPhoto: hasExistingPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ganti Foto Profil',
                      style: AppTypography.headingSmall.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pilih sumber foto untuk profil akun Anda',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildOptionCard(
            title: 'Pilih dari Galeri HP',
            subtitle: 'Ambil foto yang sudah tersimpan di perangkat',
            icon: Icons.photo_library_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFFEFF6FF),
            onTap: onPickGallery,
          ),
          const SizedBox(height: 10),
          _buildOptionCard(
            title: 'Ambil Foto dengan Kamera',
            subtitle: 'Buka kamera untuk mengambil foto baru langsung',
            icon: Icons.camera_alt_rounded,
            iconColor: AppColors.primaryDark,
            iconBgColor: AppColors.primaryContainer,
            onTap: onPickCamera,
          ),
          if (hasExistingPhoto && onRemovePhoto != null) ...[
            const SizedBox(height: 10),
            _buildOptionCard(
              title: 'Hapus Foto Profil Saat Ini',
              subtitle: 'Kembalikan tampilan ke inisial nama default',
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFDC2626),
              iconBgColor: const Color(0xFFFEE2E2),
              cardBgColor: const Color(0xFFFEF2F2),
              borderColor: const Color(0xFFFECACA),
              titleColor: const Color(0xFFDC2626),
              onTap: onRemovePhoto!,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Color? cardBgColor,
    Color? borderColor,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBgColor ?? AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor ?? AppColors.border.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: titleColor ?? AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
