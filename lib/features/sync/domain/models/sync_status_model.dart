enum SyncStatus {
  synced,
  pending,
  syncing,
  offline,
  error,
}

class SyncState {
  final SyncStatus status;
  final int pendingCount;
  final DateTime? lastSyncedAt;
  final String? lastErrorMessage;
  final bool isAutoSyncEnabled;
  final int autoSyncIntervalSeconds;
  final int lastUploadedCount;
  final int lastDownloadedCount;

  const SyncState({
    this.status = SyncStatus.synced,
    this.pendingCount = 0,
    this.lastSyncedAt,
    this.lastErrorMessage,
    this.isAutoSyncEnabled = true,
    this.autoSyncIntervalSeconds = 30,
    this.lastUploadedCount = 0,
    this.lastDownloadedCount = 0,
  });

  bool get isSyncing => status == SyncStatus.syncing;
  bool get isOffline => status == SyncStatus.offline;
  bool get hasError => status == SyncStatus.error;
  bool get isSynced => status == SyncStatus.synced && pendingCount == 0;

  SyncState copyWith({
    SyncStatus? status,
    int? pendingCount,
    DateTime? lastSyncedAt,
    String? lastErrorMessage,
    bool? isAutoSyncEnabled,
    int? autoSyncIntervalSeconds,
    int? lastUploadedCount,
    int? lastDownloadedCount,
  }) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastErrorMessage: lastErrorMessage,
      isAutoSyncEnabled: isAutoSyncEnabled ?? this.isAutoSyncEnabled,
      autoSyncIntervalSeconds: autoSyncIntervalSeconds ?? this.autoSyncIntervalSeconds,
      lastUploadedCount: lastUploadedCount ?? this.lastUploadedCount,
      lastDownloadedCount: lastDownloadedCount ?? this.lastDownloadedCount,
    );
  }
}
