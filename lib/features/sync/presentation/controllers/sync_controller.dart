import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/customer/presentation/controllers/customer_controller.dart';
import 'package:tokona/features/pos/presentation/controllers/sale_history_controller.dart';
import 'package:tokona/features/product/presentation/controllers/product_controller.dart';
import 'package:tokona/features/report/presentation/controllers/report_controller.dart';
import 'package:tokona/features/settings/presentation/controllers/app_preferences_controller.dart';
import 'package:tokona/features/sync/data/services/cloud_sync_service.dart';
import 'package:tokona/features/sync/domain/models/sync_status_model.dart';

final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>((ref) {
  return SyncController(ref);
});

class SyncController extends StateNotifier<SyncState> {
  final Ref _ref;
  Timer? _autoSyncTimer;

  SyncController(this._ref) : super(const SyncState()) {
    _initAutoSync();
  }

  void _initAutoSync() {
    final prefInterval = _ref.read(appPreferencesProvider).syncIntervalSeconds;
    state = state.copyWith(autoSyncIntervalSeconds: prefInterval);
    _startTimer();
    // Delay first check slightly so app startup finishes smoothly
    Future.delayed(const Duration(seconds: 4), () {
      refreshPendingCount();
    });
  }

  void _startTimer() {
    _autoSyncTimer?.cancel();
    if (state.isAutoSyncEnabled) {
      _autoSyncTimer = Timer.periodic(
        Duration(seconds: state.autoSyncIntervalSeconds),
        (_) => triggerSync(isManual: false),
      );
    }
  }

  Future<void> setInterval(int seconds) async {
    state = state.copyWith(autoSyncIntervalSeconds: seconds);
    _startTimer();
    try {
      final prefController = _ref.read(appPreferencesProvider.notifier);
      final currentPref = _ref.read(appPreferencesProvider);
      await prefController.save(currentPref.copyWith(syncIntervalSeconds: seconds));
    } catch (_) {}
  }

  void toggleAutoSync(bool enabled) {
    state = state.copyWith(isAutoSyncEnabled: enabled);
    if (enabled) {
      _startTimer();
    } else {
      _autoSyncTimer?.cancel();
    }
  }

  Future<void> refreshPendingCount() async {
    final store = _ref.read(authProvider).currentStore;
    if (store == null) return;

    try {
      final pending = await CloudSyncService.countPendingRecords(store.id);
      state = state.copyWith(
        pendingCount: pending,
        status: state.status == SyncStatus.syncing
            ? SyncStatus.syncing
            : (pending > 0 ? SyncStatus.pending : SyncStatus.synced),
      );
    } catch (_) {}
  }

  Future<SyncResult?> triggerSync({bool isManual = false}) async {
    if (state.isSyncing) return null;

    final authState = _ref.read(authProvider);
    final store = authState.currentStore;
    final user = authState.currentUser;
    if (store == null) return null;

    final roleLabel = (user?.role == UserRole.owner) ? 'Pusat' : 'Kasir';
    final deviceTag = 'HP_${roleLabel}_${user?.username ?? "device"}';

    state = state.copyWith(
      status: SyncStatus.syncing,
      lastErrorMessage: null,
    );

    try {
      final result = await CloudSyncService.performSync(
        storeId: store.id,
        deviceTag: deviceTag,
        lastPullTime: state.lastSyncedAt,
      );

      final newStatus = result.remainingPending > 0 ? SyncStatus.pending : SyncStatus.synced;

      state = state.copyWith(
        status: newStatus,
        pendingCount: result.remainingPending,
        lastSyncedAt: DateTime.now(),
        lastUploadedCount: result.uploadedCount,
        lastDownloadedCount: result.downloadedCount,
        lastErrorMessage: null,
      );

      // Jika ada data baru yang didownload dari HP lain, refresh data di aplikasi
      if (result.downloadedCount > 0) {
        _ref.read(productListProvider.notifier).loadProducts(store.id);
        _ref.read(saleHistoryControllerProvider.notifier).loadSales(store.id);
        _ref.read(customerListProvider.notifier).loadCustomers(store.id);
        _ref.read(reportControllerProvider.notifier).loadReport(store.id);
      }

      return result;
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      final isOffline = errStr.contains('socket') ||
          errStr.contains('timeout') ||
          errStr.contains('network') ||
          errStr.contains('unreachable') ||
          errStr.contains('failed host lookup');

      state = state.copyWith(
        status: isOffline ? SyncStatus.offline : SyncStatus.error,
        lastErrorMessage: isOffline ? 'Koneksi offline / jaringan terputus' : e.toString(),
      );
      return null;
    }
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}
