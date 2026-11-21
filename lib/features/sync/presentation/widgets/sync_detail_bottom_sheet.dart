import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/sync/presentation/controllers/sync_controller.dart';

class SyncDetailBottomSheet extends ConsumerWidget {
  const SyncDetailBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SyncDetailBottomSheet(),
    );
  }

  String _formatInterval(int seconds) {
    if (seconds < 60) return '$seconds Detik';
    if (seconds < 3600) return '${seconds ~/ 60} Menit';
    return '${seconds ~/ 3600} Jam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    final isOwner = user?.role == UserRole.owner;
    final roleName = isOwner ? 'HP Pusat (Owner)' : 'HP Kasir';

    final lastSyncText = syncState.lastSyncedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm:ss', 'id_ID').format(syncState.lastSyncedAt!)
        : 'Belum pernah sinkron';

    final availableIntervals = [15, 30, 60, 300, 900, 1800, 3600];
    final selectedInterval = availableIntervals.contains(syncState.autoSyncIntervalSeconds)
        ? syncState.autoSyncIntervalSeconds
        : 30;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sinkronisasi Data',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Atur jeda waktu penarikan data & audit log',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.7), width: 0.6),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Perangkat Ini', roleName, isHighlight: true),
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        _buildInfoRow('Terakhir Sinkron', lastSyncText),
                        const Divider(height: 14, color: Color(0xFFE2E8F0)),
                        _buildInfoRow(
                          'Data Belum Terunggah',
                          syncState.pendingCount > 0 ? '${syncState.pendingCount} data pending' : 'Semua data sinkron',
                          valueColor: syncState.pendingCount > 0 ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                        ),
                        if (syncState.lastErrorMessage != null) ...[
                          const Divider(height: 14, color: Color(0xFFE2E8F0)),
                          _buildInfoRow('Catatan', syncState.lastErrorMessage!, valueColor: AppColors.error),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Auto-Sync di Latar Belakang',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Otomatis sinkron setiap ${_formatInterval(syncState.autoSyncIntervalSeconds)} ke cloud',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    value: syncState.isAutoSyncEnabled,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => ref.read(syncControllerProvider.notifier).toggleAutoSync(val),
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interval Polling',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Jeda waktu auto-sync',
                              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: DropdownButton<int>(
                            value: selectedInterval,
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryDark),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.primaryDark),
                            onChanged: (val) {
                              if (val != null) {
                                HapticFeedback.selectionClick();
                                ref.read(syncControllerProvider.notifier).setInterval(val);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 15, child: Text('15 Detik (Cepat)')),
                              DropdownMenuItem(value: 30, child: Text('30 Detik (Standar)')),
                              DropdownMenuItem(value: 60, child: Text('1 Menit')),
                              DropdownMenuItem(value: 300, child: Text('5 Menit')),
                              DropdownMenuItem(value: 900, child: Text('15 Menit')),
                              DropdownMenuItem(value: 1800, child: Text('30 Menit')),
                              DropdownMenuItem(value: 3600, child: Text('1 Jam (Hemat)')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: syncState.isSyncing
                          ? null
                          : () async {
                              final res = await ref.read(syncControllerProvider.notifier).triggerSync(isManual: true);
                              if (context.mounted && res != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sinkron selesai: ${res.uploadedCount} diunggah, ${res.downloadedCount} diunduh.',
                                    ),
                                    backgroundColor: AppColors.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: syncState.isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sync_rounded, size: 20),
                      label: Text(
                        syncState.isSyncing ? 'Sedang Menyinkronkan...' : 'Sinkronkan Sekarang',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
