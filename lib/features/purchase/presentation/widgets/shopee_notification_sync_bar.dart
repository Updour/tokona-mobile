import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/data/services/shopee_notification_service.dart';

class ShopeeNotificationSyncBar extends ConsumerStatefulWidget {
  const ShopeeNotificationSyncBar({super.key});

  @override
  ConsumerState<ShopeeNotificationSyncBar> createState() => _ShopeeNotificationSyncBarState();
}

class _ShopeeNotificationSyncBarState extends ConsumerState<ShopeeNotificationSyncBar> {
  bool _isEnabled = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final service = ref.read(shopeeNotificationServiceProvider);
    final enabled = await service.isListenerEnabled();
    if (mounted) {
      setState(() {
        _isEnabled = enabled;
        _isChecking = false;
      });
      if (enabled) {
        final storeId = ref.read(authProvider).currentStore?.id;
        if (storeId != null) service.startListening(storeId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _isEnabled ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _isEnabled ? const Color(0xFFFFEDD5) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isEnabled ? Icons.notifications_active_outlined : Icons.notifications_paused_outlined,
            size: 15,
            color: _isEnabled ? const Color(0xFFEA580C) : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _isEnabled
                  ? 'Auto-Update Shopee aktif (Membaca notifikasi paket)'
                  : 'Aktifkan auto-lacak dari notifikasi Shopee',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: _isEnabled ? const Color(0xFF9A3412) : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () async {
              final service = ref.read(shopeeNotificationServiceProvider);
              await service.openSettings();
              await Future.delayed(const Duration(seconds: 1));
              _checkPermission();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: _isEnabled ? const Color(0xFFEA580C) : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _isEnabled ? const Color(0xFFEA580C) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Text(
                _isEnabled ? 'Aktif' : 'Nyalakan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _isEnabled ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

