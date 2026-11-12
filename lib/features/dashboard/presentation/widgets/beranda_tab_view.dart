import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/services/in_app_notification_service.dart';
import 'package:tokona/core/services/native_push_notification_service.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/backup/presentation/controllers/scheduled_backup_controller.dart';
import 'package:tokona/features/customer/presentation/widgets/kasbon_due_monitor_sheet.dart';
import 'package:tokona/features/dashboard/domain/models/app_notification_item.dart';
import 'package:tokona/features/dashboard/presentation/controllers/notification_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_booking_monitor_card.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_active_orders_card.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_header_bar.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_quick_shortcuts.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_swipeable_cards.dart';
import 'package:tokona/features/dashboard/presentation/widgets/beranda_top_products_card.dart';
import 'package:tokona/features/dashboard/presentation/widgets/daily_sales_chart_card.dart';
import 'package:tokona/features/payment/presentation/controllers/payment_account_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/pos/presentation/widgets/scheduled_reminder_sheet.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';
import 'package:tokona/features/purchase/presentation/widgets/incoming_orders_sheet.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';

class BerandaTabView extends ConsumerWidget {
  final StoreModel? store;
  final UserModel? user;
  final ValueChanged<int>? onNavigateTab;

  const BerandaTabView({
    super.key,
    required this.store,
    required this.user,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<List<AppNotificationItem>>(notificationListProvider, (prev, next) {
      if (next.isNotEmpty && (prev == null || prev.isEmpty || next.first.id != prev.first.id)) {
        final readIds = ref.read(readNotificationIdsProvider);
        if (readIds.contains(next.first.id)) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NativePushNotificationService.requestPermission();
            InAppNotificationService.show(
              context,
              next.first,
              onTap: () {
                ref.read(readNotificationIdsProvider.notifier).markAsRead(next.first.id);
                switch (next.first.targetPayload) {
                  case 'kasbon':
                    KasbonDueMonitorSheet.show(context);
                    break;
                  case 'stock':
                    onNavigateTab?.call(1);
                    break;
                  case 'booking':
                    ScheduledReminderSheet.show(context, initialTab: 0);
                    break;
                  case 'incoming':
                    IncomingOrdersSheet.show(context);
                    break;
                }
              },
            );
          }
        });
      }
    });

    if (store != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeOrdersProvider.notifier).loadOrders(store!.id);
        ref.read(scheduledBackupProvider.notifier).checkAndTriggerScheduled(storeId: store!.id, storeName: store!.name);
      });
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        if (store != null) {
          await Future.wait([
            ref.read(productListProvider.notifier).loadProducts(store!.id),
            ref.read(reportControllerProvider.notifier).loadReport(store!.id),
            ref.read(paymentAccountListProvider.notifier).loadAccounts(store!.id),
            ref.read(saleHistoryControllerProvider.notifier).loadSales(store!.id),
            ref.read(activeOrdersProvider.notifier).loadOrders(store!.id),
          ]);
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          BerandaHeaderBar(
            store: store,
            user: user,
            onNavigateTab: onNavigateTab,
          ),
          const SizedBox(height: 14),
          BerandaSwipeableCards(onNavigateTab: onNavigateTab),
          const SizedBox(height: 14),
          BerandaQuickShortcuts(onNavigateTab: onNavigateTab),
          const SizedBox(height: 16),
          const DailySalesChartCard(),
          const SizedBox(height: 14),
          const BerandaActiveOrdersCard(),
          const SizedBox(height: 14),
          const BerandaBookingMonitorCard(),
          const SizedBox(height: 14),
          BerandaTopProductsCard(
            onNavigateToProducts: () => onNavigateTab?.call(1),
          ),
        ],
      ),
    );
  }
}
