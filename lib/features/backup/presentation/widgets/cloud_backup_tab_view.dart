import 'package:flutter/material.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/backup/domain/models/cloud_backup_model.dart';
import 'package:tokona/features/backup/presentation/widgets/cloud_backup_list_tile.dart';

class CloudBackupTabView extends StatelessWidget {
  final List<CloudBackupModel> backups;
  final bool isLoading;
  final bool isProcessing;
  final VoidCallback onCreate;
  final ValueChanged<CloudBackupModel> onRestore;
  final ValueChanged<CloudBackupModel> onDelete;

  const CloudBackupTabView({
    super.key,
    required this.backups,
    required this.isLoading,
    required this.isProcessing,
    required this.onCreate,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))),
          child: const Row(
            children: [
              Icon(Icons.cloud_done_rounded, size: 18, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supabase PostgreSQL Cloud', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E40AF))),
                    Text('db.gjgfdwzqjypzalzleqgt.supabase.co:5432', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : onCreate,
            icon: isProcessing ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload_rounded, size: 16),
            label: const Text('Unggah Cadangan ke Cloud Supabase', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : backups.isEmpty
                  ? const Center(child: Text('Belum ada cadangan di Cloud Supabase', style: TextStyle(color: AppColors.textMuted, fontSize: 12)))
                  : ListView.builder(
                      itemCount: backups.length,
                      itemBuilder: (ctx, idx) => CloudBackupListTile(
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

