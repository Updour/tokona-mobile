import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void didUpdateWidget(covariant ReportSegmentedNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToActiveTab();
    }
  }

  void _scrollToActiveTab() {
    if (!_scrollController.hasClients) return;
    // Kira-kira lebar per tab ~115px dengan jarak 8px
    final targetOffset = (widget.currentIndex * 115.0) - 40;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Ringkasan', Icons.analytics_outlined, 0),
      ('Penjualan', Icons.receipt_long_outlined, 0),
      ('Pembelian', Icons.shopping_bag_outlined, 0),
      ('Pengiriman PO', Icons.local_shipping_outlined, widget.activePoCount),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final idx = entry.key;
            final tab = entry.value;
            final isSelected = widget.currentIndex == idx;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTabSelected(idx);
                  },
                  borderRadius: BorderRadius.circular(11),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 1.5),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.$2,
                          size: 14.5,
                          color: isSelected ? AppColors.primary : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          tab.$1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (tab.$3 > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${tab.$3}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : const Color(0xFF475569),
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
          }).toList(),
        ),
      ),
    );
  }
}
