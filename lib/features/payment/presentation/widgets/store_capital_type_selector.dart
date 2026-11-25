import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoreCapitalTypeSelector extends StatefulWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const StoreCapitalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  State<StoreCapitalTypeSelector> createState() => _StoreCapitalTypeSelectorState();
}

class _StoreCapitalTypeSelectorState extends State<StoreCapitalTypeSelector> {
  final ScrollController _scrollController = ScrollController();

  static const List<(String, String, IconData, Color)> _types = [
    ('TARIK_MODAL', 'Tarik Kas', Icons.remove_circle_outline_rounded, Color(0xFFDC2626)),
    ('TAMBAH_MODAL', 'Tambah Modal', Icons.add_circle_outline_rounded, Color(0xFF0D9488)),
    ('MODAL_AWAL', 'Modal Awal', Icons.flag_outlined, Color(0xFF2563EB)),
  ];

  @override
  void didUpdateWidget(covariant StoreCapitalTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final idx = _types.indexWhere((t) => t.$1 == widget.selectedType);
    if (idx < 0) return;
    final targetOffset = (idx * 110.0) - 20;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 280),
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
          children: _types.map((t) {
            final isSelected = widget.selectedType == t.$1;
            final activeColor = t.$4;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTypeSelected(t.$1);
                  },
                  borderRadius: BorderRadius.circular(11),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.07),
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
                          t.$3,
                          size: 15,
                          color: isSelected ? activeColor : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? activeColor : const Color(0xFF475569),
                            letterSpacing: -0.1,
                          ),
                        ),
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
