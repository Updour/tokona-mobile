import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/backup/domain/models/backup_file_model.dart';
import 'package:tokona/features/backup/presentation/widgets/local_backup_list_tile.dart';

class LocalBackupTabView extends StatelessWidget {
  final List<BackupFileModel> backups;
  final Map<String, dynamic> summary;
  final bool isLoading;
  final bool isProcessing;
  final VoidCallback onCreate;
  final ValueChanged<BackupFileModel> onRestore;
  final ValueChanged<BackupFileModel> onDelete;

  const LocalBackupTabView({
    super.key,
    required this.backups,
    required this.summary,
    required this.isLoading,
    required this.isProcessing,
    required this.onCreate,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final activeDbSize = summary['activeDbSize'] as int? ?? 0;
    final sizeStr = activeDbSize < 1024 ? '$activeDbSize B' : '${(activeDbSize / 1024).toStringAsFixed(1)} KB';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Database Aktif: $sizeStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('${backups.length} file .db tersimpan', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : onCreate,
            icon: isProcessing ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_alt_rounded, size: 16),
            label: const Text('Buat Cadangan Lokal Baru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : backups.isEmpty
                  ? const Center(child: Text('Belum ada cadangan lokal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)))
                  : ListView.builder(
                      itemCount: backups.length,
                      itemBuilder: (ctx, idx) => LocalBackupListTile(
                        backup: backups[idx],
                        onRestore: () => onRestore(backups[idx]),
                        onDelete: () => onDelete(backups[idx]),
                      ),
                    ),
        ),
      ],
    );
  }
}

