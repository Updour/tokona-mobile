import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tokona/features/backup/data/services/backup_service.dart';
import 'package:tokona/features/backup/data/services/supabase_backup_service.dart';
import 'package:tokona/features/backup/domain/models/scheduled_backup_config.dart';

final scheduledBackupProvider = StateNotifierProvider<ScheduledBackupController, ScheduledBackupState>((ref) {
  return ScheduledBackupController();
});

class ScheduledBackupState {
  final ScheduledBackupConfig config;
  final bool isLoading;
  final String? message;

  const ScheduledBackupState({
    required this.config,
    this.isLoading = false,
    this.message,
  });

  ScheduledBackupState copyWith({
    ScheduledBackupConfig? config,
    bool? isLoading,
    String? message,
  }) {
    return ScheduledBackupState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class ScheduledBackupController extends StateNotifier<ScheduledBackupState> {
  ScheduledBackupController() : super(const ScheduledBackupState(config: ScheduledBackupConfig())) {
    _loadConfig();
  }

  Future<File> _getConfigFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_scheduled_backup_config.json'));
  }

  Future<void> _loadConfig() async {
    try {
      final file = await _getConfigFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        state = state.copyWith(config: ScheduledBackupConfig.fromMap(map));
      }
    } catch (_) {}
  }

  Future<void> _saveConfig(ScheduledBackupConfig config) async {
    try {
      final file = await _getConfigFile();
      await file.writeAsString(jsonEncode(config.toMap()));
      state = state.copyWith(config: config);
    } catch (_) {}
  }

  Future<void> updateConfig({
    bool? isEnabled,
    String? frequency,
    int? hour,
    int? minute,
    bool? backupToLocal,
    bool? backupToCloud,
  }) async {
    final updated = state.config.copyWith(
      isEnabled: isEnabled,
      frequency: frequency,
      hour: hour,
      minute: minute,
      backupToLocal: backupToLocal,
      backupToCloud: backupToCloud,
    );
    await _saveConfig(updated);
  }

  Future<bool> runBackupNow({required String? storeId, String? storeName}) async {
    state = state.copyWith(isLoading: true, message: 'Memulai proses pencadangan data...');
    try {
      if (state.config.backupToLocal) {
        state = state.copyWith(message: 'Mencadangkan ke penyimpanan internal...');
        await BackupService.createBackup();
      }

      if (state.config.backupToCloud && storeId != null && storeId.trim().isNotEmpty) {
        state = state.copyWith(message: 'Mengunggah cadangan ke cloud Supabase...');
        await SupabaseBackupService.createCloudBackup(
          storeId: storeId,
          storeName: storeName ?? 'Tokona Store',
        );
      }

      final updated = state.config.copyWith(
        lastBackupAt: DateTime.now(),
        lastStatus: 'success',
        lastErrorMessage: null,
      );
      await _saveConfig(updated);
      state = state.copyWith(isLoading: false, message: 'Cadangan berhasil dibuat!');
      return true;
    } catch (e) {
      final updated = state.config.copyWith(
        lastBackupAt: DateTime.now(),
        lastStatus: 'failed',
        lastErrorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      await _saveConfig(updated);
      state = state.copyWith(isLoading: false, message: 'Pencadangan gagal: $e');
      return false;
    }
  }

  Future<void> checkAndTriggerScheduled({required String? storeId, String? storeName}) async {
    if (!state.config.isEnabled) return;
    final now = DateTime.now();
    final cfg = state.config;

    // Check hour & minute threshold
    if (now.hour < cfg.hour || (now.hour == cfg.hour && now.minute < cfg.minute)) {
      return;
    }

    final last = cfg.lastBackupAt;
    if (last != null) {
      if (cfg.frequency == 'daily') {
        if (last.year == now.year && last.month == now.month && last.day == now.day) {
          return;
        }
      } else if (cfg.frequency == 'weekly') {
        final diff = now.difference(last).inDays;
        if (diff < 7) return;
      } else if (cfg.frequency == 'monthly') {
        if (last.year == now.year && last.month == now.month) {
          return;
        }
      }
    }

    await runBackupNow(storeId: storeId, storeName: storeName);
  }
}

