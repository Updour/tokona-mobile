import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/core/widgets/camera_barcode_scanner.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/dashboard/presentation/controllers/notification_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/notification_center_sheet.dart';
import 'package:tokona/features/dashboard/presentation/widgets/product_quick_info_sheet.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';

class BerandaHeaderBar extends ConsumerWidget {
  final StoreModel? store;
  final UserModel? user;
  final ValueChanged<int>? onNavigateTab;

  const BerandaHeaderBar({
    super.key,
    required this.store,
    required this.user,
    this.onNavigateTab,
  });

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getTodayFormatted() {
    try {
      return DateFormat('EEEE, d MMM', 'id_ID').format(DateTime.now());
    } catch (_) {
      final now = DateTime.now();
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
    }
  }

  Future<void> _handleQuickScan(BuildContext context, WidgetRef ref) async {
    final code = await CameraBarcodeScanner.scan(context, title: 'Pindai Cek Cepat');
    if (code == null || !context.mounted) return;

    final products = ref.read(productListProvider).products;
    ProductModel? matched;
    for (final p in products) {
      if (p.sku == code || p.units.any((u) => u.barcode == code)) {
        matched = p;
        break;
      }
    }

    if (!context.mounted) return;
    if (matched != null) {
      ProductQuickInfoSheet.show(context, matched);
    } else {
      AppToast.showError(context, 'Produk dengan kode $code tidak ditemukan');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayFormatted = _getTodayFormatted();
    final notifications = ref.watch(notificationListProvider);
    final totalNotifs = notifications.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getTimeGreeting()}, ${user?.fullName ?? "Kasir"}',
                      style: AppTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store?.name ?? 'Tokona Store',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                todayFormatted,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => _handleQuickScan(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => NotificationCenterSheet.show(context, onNavigateTab: onNavigateTab),
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: totalNotifs > 0 ? const Color(0xFFFEF2F2) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: totalNotifs > 0 ? const Color(0xFFFECACA) : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      totalNotifs > 0 ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                      color: totalNotifs > 0 ? const Color(0xFFDC2626) : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  if (totalNotifs > 0)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(minWidth: 14),
                        child: Text(
                          totalNotifs > 9 ? '9+' : '$totalNotifs',
                          style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

