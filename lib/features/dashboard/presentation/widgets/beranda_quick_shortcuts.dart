import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/dashboard/domain/models/shortcut_menu_item.dart';
import 'package:tokona/features/dashboard/presentation/controllers/shortcut_controller.dart';
import 'package:tokona/features/dashboard/presentation/utils/shortcut_action_dispatcher.dart';
import 'package:tokona/features/dashboard/presentation/widgets/all_menus_sheet.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';

class BerandaQuickShortcuts extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const BerandaQuickShortcuts({super.key, this.onNavigateTab});

  @override
  ConsumerState<BerandaQuickShortcuts> createState() => _BerandaQuickShortcutsState();
}

class _BerandaQuickShortcutsState extends ConsumerState<BerandaQuickShortcuts> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinnedIds = ref.watch(shortcutControllerProvider);
    final alerts = ref.watch(alertNotificationProvider);
    final activeOrders = ref.watch(activeOrdersProvider);
    final heldOrders = ref.watch(heldCartProvider);

    final List<_ShortcutDisplayData> displayItems = [];
    for (final id in pinnedIds) {
      final meta = AppShortcutRegistry.findById(id);
      if (meta != null) {
        int badge = 0;
        bool isError = false;
        if (id == 'jadwal_wa') badge = heldOrders.length;
        if (id == 'pesanan_masuk') badge = activeOrders.length;
        if (id == 'jatuh_tempo') {
          badge = alerts.totalUrgentKasbon;
          isError = alerts.hasOverdueKasbon;
        }
        if (id == 'katalog') {
          badge = alerts.totalUrgentStock;
          isError = alerts.outOfStockCount > 0;
        }

        displayItems.add(
          _ShortcutDisplayData(
            id: meta.id,
            label: meta.label,
            icon: meta.icon,
            iconColor: meta.iconColor,
            bgColor: meta.bgColor,
            badgeCount: badge,
            isErrorBadge: isError,
            onTap: () => ShortcutActionDispatcher.dispatch(
              context,
              ref,
              meta.id,
              onNavigateTab: widget.onNavigateTab,
            ),
          ),
        );
      }
    }

    // Always append the "Semua" button
    displayItems.add(
      _ShortcutDisplayData(
        id: 'semua',
        label: 'Semua',
        icon: Icons.grid_view_rounded,
        iconColor: const Color(0xFF475569),
        bgColor: const Color(0xFFF1F5F9),
        badgeCount: 0,
        isErrorBadge: false,
        onTap: () => AllMenusSheet.show(context, onNavigateTab: widget.onNavigateTab),
      ),
    );

    // Split into pages of 8 items (2 rows x 4 items per page)
    const int pageSize = 8;
    final int pageCount = (displayItems.length / pageSize).ceil();
    final List<List<_ShortcutDisplayData>> pages = [];
    for (int i = 0; i < pageCount; i++) {
      final start = i * pageSize;
      final end = (start + pageSize < displayItems.length) ? start + pageSize : displayItems.length;
      pages.add(displayItems.sublist(start, end));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 154,
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (idx) {
                HapticFeedback.selectionClick();
                setState(() => _currentPage = idx);
              },
              itemBuilder: (context, pageIdx) {
                return _buildGridPage(context, pages[pageIdx]);
              },
            ),
          ),
          if (pageCount > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pageCount, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: isActive ? 14 : 5,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridPage(BuildContext context, List<_ShortcutDisplayData> items) {
    final row1 = items.take(4).toList();
    final row2 = items.skip(4).take(4).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(4, (index) {
            if (index < row1.length) {
              return Expanded(child: _buildItemTile(context, row1[index]));
            }
            return const Expanded(child: SizedBox.shrink());
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            if (index < row2.length) {
              return Expanded(child: _buildItemTile(context, row2[index]));
            }
            return const Expanded(child: SizedBox.shrink());
          }),
        ),
      ],
    );
  }

  Widget _buildItemTile(BuildContext context, _ShortcutDisplayData item) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        item.onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.bgColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 21),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: item.isErrorBadge ? AppColors.error : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
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
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutDisplayData {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final int badgeCount;
  final bool isErrorBadge;
  final VoidCallback onTap;

  const _ShortcutDisplayData({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.badgeCount,
    required this.isErrorBadge,
    required this.onTap,
  });
}
