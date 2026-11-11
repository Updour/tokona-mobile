import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/providers/alert_notification_provider.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/dashboard/domain/models/shortcut_menu_item.dart';
import 'package:tokona/features/dashboard/presentation/controllers/shortcut_controller.dart';
import 'package:tokona/features/dashboard/presentation/widgets/all_menus_category_section.dart';
import 'package:tokona/features/pos/presentation/controllers/held_cart_controller.dart';
import 'package:tokona/features/purchase/presentation/controllers/active_orders_controller.dart';

class AllMenusSheet extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const AllMenusSheet({super.key, this.onNavigateTab});

  static Future<void> show(BuildContext context, {ValueChanged<int>? onNavigateTab}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AllMenusSheet(onNavigateTab: onNavigateTab),
    );
  }

  @override
  ConsumerState<AllMenusSheet> createState() => _AllMenusSheetState();
}

class _AllMenusSheetState extends ConsumerState<AllMenusSheet> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final pinnedIds = ref.watch(shortcutControllerProvider);
    final alerts = ref.watch(alertNotificationProvider);
    final activeOrders = ref.watch(activeOrdersProvider);
    final heldOrders = ref.watch(heldCartProvider);

    const categories = [
      'Kasir & Penjualan',
      'Produk & Inventaris',
      'Keuangan & Laporan',
      'Pelanggan & Relasi',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(pinnedIds.length),
            if (_isEditMode) _buildEditHint(pinnedIds.length),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  for (final cat in categories)
                    AllMenusCategorySection(
                      category: cat,
                      items: AppShortcutRegistry.all.where((e) => e.category == cat).toList(),
                      pinnedIds: pinnedIds,
                      isEditMode: _isEditMode,
                      alerts: alerts,
                      activeOrdersCount: activeOrders.length,
                      heldOrdersCount: heldOrders.length,
                      onNavigateTab: widget.onNavigateTab,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int pinnedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Semua Menu & Fitur',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      _isEditMode ? 'Pilih pintasan untuk Beranda' : 'Katalog lengkap fitur Tokona',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _isEditMode = !_isEditMode);
                },
                style: TextButton.styleFrom(
                  backgroundColor: _isEditMode ? AppColors.primary : AppColors.surface,
                  foregroundColor: _isEditMode ? Colors.white : AppColors.primary,
                  side: BorderSide(color: _isEditMode ? AppColors.primary : AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(_isEditMode ? Icons.check_rounded : Icons.edit_note_rounded, size: 16),
                label: Text(
                  _isEditMode ? 'Selesai' : 'Atur',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditHint(int pinnedCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Centang menu yang ingin dipasang di Beranda ($pinnedCount terpilih).',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(shortcutControllerProvider.notifier).resetToDefault();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
          ),
        ],
      ),
    );
  }
}
