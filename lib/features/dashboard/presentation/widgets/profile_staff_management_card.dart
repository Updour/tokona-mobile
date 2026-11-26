import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/auth/presentation/widgets/add_staff_dialog.dart';
import 'package:tokona/features/auth/presentation/widgets/staff_management_sheet.dart';
import 'package:tokona/features/settings/presentation/widgets/rbac_management_sheet.dart';

class ProfileStaffManagementCard extends ConsumerWidget {
  const ProfileStaffManagementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    final store = ref.watch(authProvider).currentStore;

    if (user == null || !user.isOwner || store == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengguna & Pairing Kasir',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Kelola staf & scan pairing login di HP masing-masing',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.devices_rounded, size: 10.5, color: AppColors.primaryDark),
                    SizedBox(width: 3.5),
                    Text(
                      'Multi-Device',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      AddStaffDialog.show(context, storeId: store.id, onStaffAdded: () {});
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 15, color: Colors.white),
                    label: const Text('+ Tambah Staf', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      StaffManagementSheet.show(context);
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 15, color: AppColors.primaryDark),
                    label: const Text('Pairing', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
                      backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.45),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              RbacManagementSheet.show(context);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.5),
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 15, color: AppColors.primary),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Atur Hak Akses Menu Kasir & Admin',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primaryDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
