import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';

class ReportSegmentedNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final int activePoCount;

  const ReportSegmentedNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.activePoCount = 0,
  });

  @override
  State<ReportSegmentedNav> createState() => _ReportSegmentedNavState();
}

class _ReportSegmentedNavState extends State<ReportSegmentedNav> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tabKeys = List.generate(4, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant ReportSegmentedNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToSelectedTab();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _tabKeys[widget.currentIndex];
      final currentContext = key.currentContext;
      if (currentContext != null) {
        Scrollable.ensureVisible(
          currentContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Ringkasan', Icons.analytics_outlined, 0),
      ('Penjualan', Icons.receipt_long_outlined, 0),
      ('Pembelian', Icons.shopping_bag_outlined, 0),
      ('PO & OTW', Icons.local_shipping_outlined, widget.activePoCount),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final tab = tabs[idx];
          final isSelected = widget.currentIndex == idx;

          return KeyedSubtree(
            key: _tabKeys[idx],
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onTabSelected(idx),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.$2,
                        size: 15,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        tab.$1,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (tab.$3 > 0) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tab.$3}',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppColors.primary : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
