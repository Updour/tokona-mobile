import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

class SettingsShippingTab extends StatelessWidget {
  final AppPreferences draft;
  final ValueChanged<AppPreferences> onChanged;

  const SettingsShippingTab({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 14),
      children: [
        _sectionTitle('Penerimaan Paket Otomatis', Icons.local_shipping_rounded, const Color(0xFF0D9488)),
        _card(
          children: [
            _switchRow(
              title: 'Auto-Terima saat Paket Tiba',
              subtitle: draft.autoReceiveOnDelivered
                  ? 'Stok masuk gudang otomatis saat kurir update Terkirim'
                  : 'Hanya notifikasi — terima fisik barang manual',
              value: draft.autoReceiveOnDelivered,
              onChanged: (v) => onChanged(draft.copyWith(autoReceiveOnDelivered: v)),
            ),
            const Divider(height: 12, color: Color(0xFFF1F5F9)),
            _switchRow(
              title: 'Auto-Terima saat Lewat Estimasi',
              subtitle: draft.autoReceiveOnExpiredEstimate
                  ? 'Otomatis terima jika lewat batas tanggal estimasi tiba'
                  : 'Pesanan tetap menunggu konfirmasi manual',
              value: draft.autoReceiveOnExpiredEstimate,
              onChanged: (v) => onChanged(draft.copyWith(autoReceiveOnExpiredEstimate: v)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionTitle('Filter Lacak Resi', Icons.qr_code_scanner_rounded, const Color(0xFF0284C7)),
        _card(
          children: [
            _switchRow(
              title: 'Deteksi Khusus J&T Cargo',
              subtitle: 'Lacak resi berformat [J&T Cargo] secara otomatis',
              value: draft.strictCourierPrefixDetection,
              onChanged: (v) => onChanged(draft.copyWith(strictCourierPrefixDetection: v)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF16A34A)),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Resi tanpa tag atau berlabel [J&T Cargo] disinkronkan otomatis. Kurir lain dilewati.',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF15803D)),
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
