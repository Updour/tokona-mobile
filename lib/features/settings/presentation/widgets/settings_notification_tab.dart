import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class SettingsNotificationTab extends StatelessWidget {
  final AppPreferences draft;
  final TextEditingController paylaterNameController;
  final ValueChanged<AppPreferences> onChanged;

  const SettingsNotificationTab({
    super.key,
    required this.draft,
    required this.paylaterNameController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 14),
      children: [
        _sectionTitle('Tagihan Paylater', Icons.credit_card_rounded, const Color(0xFF0284C7)),
        _card(
          children: [
            TextField(
              controller: paylaterNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Layanan',
                hintText: 'SPayLater / GoPayLater',
                isDense: true,
              ),
              onChanged: (v) => onChanged(draft.copyWith(paylaterName: v.trim().isEmpty ? 'SPayLater' : v.trim())),
            ),
            const SizedBox(height: 10),
            _stepperRow(
              label: 'Jatuh Tempo',
              subtitle: 'Tanggal ${draft.paylaterDueDay} tiap bulan',
              valueText: 'Tgl ${draft.paylaterDueDay}',
              onDec: () => onChanged(draft.copyWith(paylaterDueDay: (draft.paylaterDueDay - 1).clamp(1, 28))),
              onInc: () => onChanged(draft.copyWith(paylaterDueDay: (draft.paylaterDueDay + 1).clamp(1, 28))),
            ),
            const Divider(height: 14, color: Color(0xFFF1F5F9)),
            _stepperRow(
              label: 'Mulai Pengingat',
              subtitle: 'Ingatkan H-${draft.paylaterRemindDaysBefore} sebelum tempo',
              valueText: 'H-${draft.paylaterRemindDaysBefore}',
              onDec: () => onChanged(draft.copyWith(paylaterRemindDaysBefore: (draft.paylaterRemindDaysBefore - 1).clamp(0, 10))),
              onInc: () => onChanged(draft.copyWith(paylaterRemindDaysBefore: (draft.paylaterRemindDaysBefore + 1).clamp(0, 10))),
            ),
            const Divider(height: 14, color: Color(0xFFF1F5F9)),
            _stepperRow(
              label: 'Jam Notifikasi',
              subtitle: 'Push notif HP pukul ${draft.paylaterRemindHour.toString().padLeft(2, '0')}:00',
              valueText: '${draft.paylaterRemindHour.toString().padLeft(2, '0')}:00',
              onDec: () => onChanged(draft.copyWith(paylaterRemindHour: (draft.paylaterRemindHour - 1).clamp(0, 23))),
              onInc: () => onChanged(draft.copyWith(paylaterRemindHour: (draft.paylaterRemindHour + 1).clamp(0, 23))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionTitle('Kasbon & Booking', Icons.notifications_active_rounded, const Color(0xFF0D9488)),
        _card(
          children: [
            _stepperRow(
              label: 'Pengingat Kasbon',
              subtitle: 'Notif H-${draft.kasbonRemindDaysBefore} sebelum jatuh tempo',
              valueText: '${draft.kasbonRemindDaysBefore} hr',
              onDec: () => onChanged(draft.copyWith(kasbonRemindDaysBefore: (draft.kasbonRemindDaysBefore - 1).clamp(1, 14))),
              onInc: () => onChanged(draft.copyWith(kasbonRemindDaysBefore: (draft.kasbonRemindDaysBefore + 1).clamp(1, 14))),
            ),
            const Divider(height: 14, color: Color(0xFFF1F5F9)),
            _stepperRow(
              label: 'Jadwal Booking',
              subtitle: 'Ingatkan ${draft.bookingRemindMinutesBefore} menit sebelum jam ambil',
              valueText: '${draft.bookingRemindMinutesBefore} mnt',
              onDec: () => onChanged(draft.copyWith(bookingRemindMinutesBefore: (draft.bookingRemindMinutesBefore - 5).clamp(5, 180))),
              onInc: () => onChanged(draft.copyWith(bookingRemindMinutesBefore: (draft.bookingRemindMinutesBefore + 5).clamp(5, 180))),
            ),
            const Divider(height: 14, color: Color(0xFFF1F5F9)),
            _stepperRow(
              label: 'Riwayat Paket Tiba',
              subtitle: 'Tersimpan selama ${draft.deliveryHistoryDays} hari',
              valueText: '${draft.deliveryHistoryDays} hr',
              onDec: () => onChanged(draft.copyWith(deliveryHistoryDays: (draft.deliveryHistoryDays - 1).clamp(1, 30))),
              onInc: () => onChanged(draft.copyWith(deliveryHistoryDays: (draft.deliveryHistoryDays + 1).clamp(1, 30))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionTitle('Tampilan & Suara', Icons.tune_rounded, const Color(0xFF6366F1)),
        _card(
          children: [
            _switchRow(
              title: 'Sembunyikan Tab Kosong',
              subtitle: 'Sembunyikan tab dengan 0 pesan otomatis',
              value: draft.hideEmptyNotificationTabs,
              onChanged: (v) => onChanged(draft.copyWith(hideEmptyNotificationTabs: v)),
            ),
            const Divider(height: 12, color: Color(0xFFF1F5F9)),
            _switchRow(
              title: 'Push Notif Paket Tiba',
              subtitle: 'Notif status bar saat kurir kirim konfirmasi',
              value: draft.pushDeliveryEnabled,
              onChanged: (v) => onChanged(draft.copyWith(pushDeliveryEnabled: v)),
            ),
            const Divider(height: 12, color: Color(0xFFF1F5F9)),
            _switchRow(
              title: 'Push Notif Paylater',
              subtitle: 'Notif status bar saat mendekati batas tempo',
              value: draft.pushPaylaterEnabled,
              onChanged: (v) => onChanged(draft.copyWith(pushPaylaterEnabled: v)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _stepperRow({
    required String label,
    required String subtitle,
    required String valueText,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 1),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onDec,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                child: const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.remove_rounded, size: 14, color: Color(0xFF475569))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text(valueText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ),
              InkWell(
                onTap: onInc,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                child: const Padding(padding: EdgeInsets.all(5), child: Icon(Icons.add_rounded, size: 14, color: Color(0xFF475569))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
    );
  }
}
