import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/core/theme/app_colors.dart';
import 'package:tokona/features/sync/domain/models/sync_status_model.dart';
import 'package:tokona/features/sync/presentation/controllers/sync_controller.dart';
import 'package:tokona/features/sync/presentation/widgets/sync_detail_bottom_sheet.dart';

class SyncStatusPill extends ConsumerStatefulWidget {
  final bool showLabel;
  const SyncStatusPill({super.key, this.showLabel = true});

  @override
  ConsumerState<SyncStatusPill> createState() => _SyncStatusPillState();
}

class _SyncStatusPillState extends ConsumerState<SyncStatusPill> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    final syncState = ref.read(syncControllerProvider);

    if (syncState.isSyncing) return;

    final res = await ref.read(syncControllerProvider.notifier).triggerSync(isManual: true);
    if (!mounted) return;

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.uploadedCount > 0 || res.downloadedCount > 0
                ? 'Sinkron berhasil: ↑${res.uploadedCount} ↓${res.downloadedCount}'
                : 'Data sudah yang paling baru (tersinkron).',
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final err = ref.read(syncControllerProvider).lastErrorMessage;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncControllerProvider);

    if (syncState.isSyncing) {
      if (!_rotationController.isAnimating) _rotationController.repeat();
    } else {
      if (_rotationController.isAnimating) _rotationController.stop();
    }

    Color bgColor;
    Color borderColor;
    Color contentColor;
    IconData icon;
    String label;

    switch (syncState.status) {
      case SyncStatus.syncing:
        bgColor = const Color(0xFFE0F2FE);
        borderColor = const Color(0xFF7DD3FC);
        contentColor = const Color(0xFF0369A1);
        icon = Icons.sync_rounded;
        label = 'Syncing...';
        break;
      case SyncStatus.pending:
        bgColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        contentColor = const Color(0xFFB45309);
        icon = Icons.cloud_upload_rounded;
        label = '${syncState.pendingCount} Pending';
        break;
      case SyncStatus.offline:
        bgColor = const Color(0xFFF1F5F9);
        borderColor = const Color(0xFFCBD5E1);
        contentColor = const Color(0xFF475569);
        icon = Icons.cloud_off_rounded;
        label = 'Offline';
        break;
      case SyncStatus.error:
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        contentColor = const Color(0xFFB91C1C);
        icon = Icons.sync_problem_rounded;
        label = 'Gagal';
        break;
      case SyncStatus.synced:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        contentColor = const Color(0xFF15803D);
        icon = Icons.cloud_done_rounded;
        label = 'Cloud Sync';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          SyncDetailBottomSheet.show(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (syncState.isSyncing)
                RotationTransition(
                  turns: _rotationController,
                  child: Icon(icon, size: 14, color: contentColor),
                )
              else
                Icon(icon, size: 14, color: contentColor),
              if (widget.showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: contentColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
