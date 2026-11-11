import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/dashboard/presentation/widgets/profile_settings_sheet.dart';

class ProfileHeader extends StatelessWidget {
  final StoreModel? store;
  final UserModel? user;

  const ProfileHeader({
    super.key,
    required this.store,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil & Toko', style: AppTypography.headingMedium),
              const SizedBox(height: 3),
              Text(
                'Kelola identitas kasir dan operasional sistem',
                style: AppTypography.bodySmall.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary, size: 22),
            tooltip: 'Pengaturan & Preferensi Sistem',
            onPressed: () => ProfileSettingsSheet.show(context, store: store, user: user),
          ),
        ),
      ],
    );
  }
}

