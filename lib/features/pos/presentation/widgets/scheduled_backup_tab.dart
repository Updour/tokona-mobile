import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/core/widgets/app_toast.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/backup/presentation/controllers/scheduled_backup_controller.dart';
import 'package:tokona/features/backup/presentation/widgets/backup_restore_bottom_sheet.dart';

class ScheduledBackupTab extends ConsumerWidget {
  const ScheduledBackupTab({super.key});

  Future<void> _pickTime(BuildContext context, WidgetRef ref, int currentHour, int currentMinute) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      helpText: 'PILIH JAM BACKUP OTOMATIS',
    );
    if (picked != null) {
      await ref.read(scheduledBackupProvider.notifier).updateConfig(hour: picked.hour, minute: picked.minute);
      if (context.mounted) AppToast.showSuccess(context, 'Jam backup diatur ke ${picked.format(context)}');
    }
  }

  Future<void> _handleManualBackup(BuildContext context, WidgetRef ref, String? storeId, String? storeName) async {
    final success = await ref.read(scheduledBackupProvider.notifier).runBackupNow(storeId: storeId, storeName: storeName);
    if (!context.mounted) return;
    if (success) {
      AppToast.showSuccess(context, 'Data berhasil dicadangkan!');
    } else {
      AppToast.showError(context, 'Gagal mencadangkan data');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(authProvider).currentStore;
    final state = ref.watch(scheduledBackupProvider);
    final cfg = state.config;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToggleCard(context, ref, cfg),
          const SizedBox(height: 12),
          _buildFrequencySection(ref, cfg),
          const SizedBox(height: 12),
          _buildTimeCard(context, ref, cfg),
          const SizedBox(height: 12),
          _buildDestinationsCard(ref, cfg),
          const SizedBox(height: 12),
          _buildLastStatusCard(cfg),
          const SizedBox(height: 16),
          _buildActionButtons(context, ref, state, store?.id, store?.name),
        ],
      ),
    );
  }

  Widget _buildToggleCard(BuildContext context, WidgetRef ref, dynamic cfg) {
    final active = cfg.isEnabled as bool;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? const Color(0xFF86EFAC) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(active ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, color: active ? const Color(0xFF16A34A) : AppColors.textMuted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pencadangan Otomatis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                Text(active ? 'Aktif sesuai jadwal' : 'Nonaktif (manual saja)', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch.adaptive(
            value: active,
            activeColor: const Color(0xFF16A34A),
            onChanged: (val) => ref.read(scheduledBackupProvider.notifier).updateConfig(isEnabled: val),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection(WidgetRef ref, dynamic cfg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frekuensi Backup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildFreqChip(ref, cfg, 'daily', 'Harian'),
            const SizedBox(width: 8),
            _buildFreqChip(ref, cfg, 'weekly', 'Mingguan'),
            const SizedBox(width: 8),
            _buildFreqChip(ref, cfg, 'monthly', 'Bulanan'),
          ],
        ),
      ],
    );
  }

  Widget _buildFreqChip(WidgetRef ref, dynamic cfg, String val, String label) {
    final isSelected = cfg.frequency == val;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(scheduledBackupProvider.notifier).updateConfig(frequency: val),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F766E) : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF0F766E) : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context, WidgetRef ref, dynamic cfg) {
    return InkWell(
      onTap: () => _pickTime(context, ref, cfg.hour, cfg.minute),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_filled_rounded, size: 20, color: Color(0xFF0F766E)),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jam Eksekusi Backup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('Disarankan saat toko tutup atau malam hari', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${cfg.timeFormatted} WIB',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F766E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationsCard(WidgetRef ref, dynamic cfg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tujuan Cadangan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: cfg.backupToLocal,
            activeColor: const Color(0xFF0F766E),
            title: const Text('Simpan ke Memori HP (Lokal)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            subtitle: const Text('Aman jika offline / tanpa koneksi', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            onChanged: (v) => ref.read(scheduledBackupProvider.notifier).updateConfig(backupToLocal: v ?? true),
          ),
          const Divider(height: 1),
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: cfg.backupToCloud,
            activeColor: const Color(0xFF0F766E),
            title: const Text('Upload ke Cloud Supabase', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            subtitle: const Text('Tersimpan di cloud anti hilang', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            onChanged: (v) => ref.read(scheduledBackupProvider.notifier).updateConfig(backupToCloud: v ?? true),
          ),
        ],
      ),
    );
  }

  Widget _buildLastStatusCard(dynamic cfg) {
    final isSuccess = cfg.lastStatus == 'success';
    final isFailed = cfg.lastStatus == 'failed';
    final timeStr = cfg.lastBackupAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(cfg.lastBackupAt!)
        : 'Belum pernah dicadangkan';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFF0FDF4) : (isFailed ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSuccess ? const Color(0xFF86EFAC) : (isFailed ? const Color(0xFFFCA5A5) : AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : (isFailed ? Icons.error_rounded : Icons.history_rounded),
            color: isSuccess ? const Color(0xFF16A34A) : (isFailed ? AppColors.error : AppColors.textMuted),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSuccess ? 'Backup Terakhir Sukses' : (isFailed ? 'Backup Terakhir Gagal' : 'Riwayat Backup Terakhir'),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSuccess ? const Color(0xFF15803D) : (isFailed ? AppColors.error : AppColors.textPrimary),
                  ),
                ),
                Text(timeStr, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic state, String? storeId, String? storeName) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : () => _handleManualBackup(context, ref, storeId, storeName),
            icon: state.isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.backup_rounded, size: 16),
            label: Text(
              state.isLoading ? 'Sedang Mencadangkan...' : 'Cadangkan Sekarang',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => BackupRestoreBottomSheet.show(context),
            icon: const Icon(Icons.restore_page_rounded, size: 16),
            label: const Text('Buka Kelola & Pulihkan Data Lengkap', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
