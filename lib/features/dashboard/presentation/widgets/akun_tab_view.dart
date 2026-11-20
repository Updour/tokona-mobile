import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_dialog.dart';
import 'package:tokona/core/widgets/app_loading_overlay.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_menu_section.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_shopee_header.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_shopee_quick_bar.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_staff_management_card.dart';
import 'package:tokona/features/dashboard/presentation/widgets/store_profile_incomplete_banner.dart';
import 'package:tokona/features/settings/presentation/widgets/dynamic_settings_menu_card.dart';

class AkunTabView extends ConsumerWidget {
  final StoreModel? store;
  final UserModel? user;

  const AkunTabView({
    super.key,
    required this.store,
    required this.user,
  });

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.showConfirmation(
      context,
      title: 'Keluar dari Akun',
      message: 'Apakah Anda yakin ingin keluar? Anda perlu login kembali untuk mengakses kasir dan data toko.',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );
    if (confirmed == true) {
      if (context.mounted) {
        await AppLoadingOverlay.show(
          context,
          title: 'Mengamankan Sesi Kasir...',
          subtitle: 'Menyimpan data transaksi lokal & membersihkan sesi perangkat.',
          icon: Icons.lock_clock_rounded,
          duration: const Duration(milliseconds: 2000),
        );
      }
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 40),
      children: [
        ProfileShopeeHeader(store: store, user: user),
        const SizedBox(height: 14),
        const StoreProfileIncompleteBanner(),
        const ProfileShopeeQuickBar(),
        const SizedBox(height: 16),
        const ProfileStaffManagementCard(),
        const DynamicSettingsMenuCard(),
        const ProfileMenuSection(),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _handleLogout(context, ref),
          icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
          label: const Text(
            'Keluar dari Akun',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
              color: AppColors.error,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            side: const BorderSide(color: Color(0xFFFCA5A5)),
            backgroundColor: const Color(0xFFFEF2F2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
