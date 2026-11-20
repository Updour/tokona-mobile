import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/theme/app_typography.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';
import 'package:tokona/features/settings/presentation/widgets/settings_notification_tab.dart';
import 'package:tokona/features/settings/presentation/widgets/settings_shipping_tab.dart';
import 'package:tokona/features/settings/presentation/widgets/settings_stock_wa_tab.dart';

class DynamicSettingsSheet extends ConsumerStatefulWidget {
  final int initialTab;

  const DynamicSettingsSheet({super.key, this.initialTab = 0});

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DynamicSettingsSheet(initialTab: initialTab),
    );
  }

  @override
  ConsumerState<DynamicSettingsSheet> createState() => _DynamicSettingsSheetState();
}

class _DynamicSettingsSheetState extends ConsumerState<DynamicSettingsSheet> {
  late int _tabIndex;
  late AppPreferences _draft;

  late final TextEditingController _paylaterNameCtrl;
  late final TextEditingController _minStockCtrl;
  late final TextEditingController _waBookingCtrl;
  late final TextEditingController _waKasbonCtrl;
  late final TextEditingController _waOrderCtrl;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 2);
    _draft = ref.read(appPreferencesProvider);
    _paylaterNameCtrl = TextEditingController(text: _draft.paylaterName);
    _minStockCtrl = TextEditingController(
      text: _draft.defaultMinStockAlert == _draft.defaultMinStockAlert.roundToDouble()
          ? _draft.defaultMinStockAlert.toInt().toString()
          : _draft.defaultMinStockAlert.toString(),
    );
    _waBookingCtrl = TextEditingController(text: _draft.waBookingTemplate);
    _waKasbonCtrl = TextEditingController(text: _draft.waKasbonTemplate);
    _waOrderCtrl = TextEditingController(text: _draft.waOrderTemplate);
  }

  @override
  void dispose() {
    _paylaterNameCtrl.dispose();
    _minStockCtrl.dispose();
    _waBookingCtrl.dispose();
    _waKasbonCtrl.dispose();
    _waOrderCtrl.dispose();
    super.dispose();
  }

  void _resetDefaults() {
    const def = AppPreferences();
    setState(() {
      _draft = def;
      _paylaterNameCtrl.text = def.paylaterName;
      _minStockCtrl.text = def.defaultMinStockAlert.toInt().toString();
      _waBookingCtrl.text = def.waBookingTemplate;
      _waKasbonCtrl.text = def.waKasbonTemplate;
      _waOrderCtrl.text = def.waOrderTemplate;
    });
    AppToast.showInfo(context, 'Reset ke pengaturan awal');
  }

  Future<void> _save() async {
    HapticFeedback.lightImpact();
    await ref.read(appPreferencesProvider.notifier).save(_draft);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppToast.showSuccess(context, 'Pengaturan disimpan');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF334155), size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferensi Toko', style: AppTypography.headingSmall.copyWith(fontSize: 15, fontWeight: FontWeight.w800)),
                    const Text('Atur pengingat, kurir, dan template pesan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _resetDefaults,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('Reset', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab(0, 'Notifikasi', Icons.notifications_rounded),
                _buildTab(1, 'Pengiriman', Icons.local_shipping_rounded),
                _buildTab(2, 'Stok & WA', Icons.chat_rounded),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                SettingsNotificationTab(
                  draft: _draft,
                  paylaterNameController: _paylaterNameCtrl,
                  onChanged: (next) => setState(() => _draft = next),
                ),
                SettingsShippingTab(
                  draft: _draft,
                  onChanged: (next) => setState(() => _draft = next),
                ),
                SettingsStockWaTab(
                  draft: _draft,
                  minStockController: _minStockCtrl,
                  waBookingController: _waBookingCtrl,
                  waKasbonController: _waKasbonCtrl,
                  waOrderController: _waOrderCtrl,
                  onChanged: (next) => setState(() => _draft = next),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 17, color: Colors.white),
            label: const Text('Simpan Pengaturan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final active = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13.5, color: active ? AppColors.primary : const Color(0xFF64748B)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.textPrimary : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
