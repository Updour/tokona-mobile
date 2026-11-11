import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/customer/presentation/widgets/customer_list_bottom_sheet.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/payment/presentation/widgets/payment_account_management_sheet.dart';
import 'package:tokona/features/pos/presentation/widgets/sales_history_sheet.dart';
import 'package:tokona/features/purchase/presentation/widgets/add_purchase_bottom_sheet.dart';

class ProfileShopeeQuickBar extends ConsumerWidget {
  const ProfileShopeeQuickBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertNotificationProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.receipt_long_rounded,
              iconColor: const Color(0xFF0D9488),
              bgColor: const Color(0xFFCCFBF1),
              label: 'Penjualan',
              onTap: () => SalesHistorySheet.show(context),
            ),
          ),
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.people_alt_rounded,
              iconColor: const Color(0xFF6366F1),
              bgColor: const Color(0xFFEEF2FF),
              label: 'Pelanggan',
              onTap: () => CustomerListBottomSheet.show(context),
            ),
          ),
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.event_note_rounded,
              iconColor: alerts.hasOverdueKasbon ? const Color(0xFFDC2626) : const Color(0xFFD97706),
              bgColor: alerts.hasOverdueKasbon ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
              label: 'Tempo',
              badgeCount: alerts.totalUrgentKasbon,
              isError: alerts.hasOverdueKasbon,
              onTap: () => KasbonDueMonitorSheet.show(context),
            ),
          ),
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              label: 'Kas',
              onTap: () => PaymentAccountManagementSheet.show(context),
            ),
          ),
          Expanded(
            child: _buildQuickAction(
              context,
              icon: Icons.add_shopping_cart_rounded,
              iconColor: const Color(0xFF0284C7),
              bgColor: const Color(0xFFE0F2FE),
              label: 'Restok',
              badgeCount: alerts.totalUrgentStock,
              isError: alerts.outOfStockCount > 0,
              onTap: () => AddPurchaseBottomSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
    int badgeCount = 0,
    bool isError = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.15),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -2,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isError ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
