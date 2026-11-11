import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/dashboard/presentation/widgets/store_edit_bottom_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/category_type_sheet.dart';
import 'package:tokona/features/product/presentation/widgets/packaging_info_dialog.dart';

class ProfileSettingsSheet extends ConsumerWidget {
  final StoreModel? store;
  final UserModel? user;

  const ProfileSettingsSheet({
    super.key,
    required this.store,
    required this.user,
  });

  static Future<void> show(BuildContext context, {StoreModel? store, UserModel? user}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSettingsSheet(store: store, user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.settings_suggest_rounded, color: AppColors.primaryDark, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pengaturan & Preferensi', style: AppTypography.headingSmall.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('Kelola konfigurasi sistem Tokona POS', style: AppTypography.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildSettingTile(
                  icon: Icons.storefront_rounded,
                  color: AppColors.primary,
                  title: 'Informasi Toko',
                  subtitle: '${store?.name ?? "Tokona Store"} • Klik untuk edit nama, alamat & nomor',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Ubah', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    StoreEditBottomSheet.show(context, store: store);
                  },
                ),
                _buildSettingTile(
                  icon: Icons.print_outlined,
                  color: const Color(0xFF4F46E5),
                  title: 'Printer Struk Kasir',
                  subtitle: 'Format 58mm / 80mm • ESC/POS Bluetooth',
                  onTap: () {
                    Navigator.of(context).pop();
                    AppToast.showInfo(context, 'Pengaturan printer thermal ESC/POS aktif');
                  },
                ),
                _buildSettingTile(
                  icon: Icons.volume_up_outlined,
                  color: const Color(0xFF0D9488),
                  title: 'Suara & Efek Sentuhan Kasir',
                  subtitle: 'Haptic feedback dan respon audio kasir',
                  trailing: Switch(
                    value: true,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      AppToast.showSuccess(context, 'Efek haptic kasir aktif');
                    },
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.category_outlined,
                  color: const Color(0xFFF59E0B),
                  title: 'Master Kategori & Tipe Produk',
                  subtitle: 'Kelola kategori barang untuk filter kasir',
                  onTap: () {
                    Navigator.of(context).pop();
                    CategoryTypeSheet.show(context);
                  },
                ),
                _buildSettingTile(
                  icon: Icons.layers_outlined,
                  color: const Color(0xFF0284C7),
                  title: 'Satuan Kemasan Bertingkat',
                  subtitle: 'Konversi multi-satuan Dus, Lusin, dan Pcs',
                  onTap: () {
                    Navigator.of(context).pop();
                    PackagingInfoDialog.show(context);
                  },
                ),
                _buildSettingTile(
                  icon: Icons.storage_rounded,
                  color: const Color(0xFF10B981),
                  title: 'Status Database SQLite',
                  subtitle: 'Penyimpanan lokal offline-first aman & cepat',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.successContainer, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Tersinkron', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
                ),
                _buildSettingTile(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Tokona POS v1.0.0 • Retail & Grosir Indonesia',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Tokona POS Retail',
                      applicationVersion: '1.0.0+1',
                      applicationLegalese: '© 2026 Tokona POS - Solusi Kasir Retail & Grosir Indonesia',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}

