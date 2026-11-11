class ScheduledBackupConfig {
  final bool isEnabled;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final int hour; // 0-23
  final int minute; // 0-59
  final bool backupToLocal;
  final bool backupToCloud;
  final DateTime? lastBackupAt;
  final String? lastStatus;
  final String? lastErrorMessage;

  const ScheduledBackupConfig({
    this.isEnabled = true,
    this.frequency = 'daily',
    this.hour = 22,
    this.minute = 0,
    this.backupToLocal = true,
    this.backupToCloud = true,
    this.lastBackupAt,
    this.lastStatus,
    this.lastErrorMessage,
  });

  String get timeFormatted {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get frequencyLabel {
    switch (frequency) {
      case 'weekly':
        return 'Mingguan (Tiap Senin)';
      case 'monthly':
        return 'Bulanan (Tgl 1)';
      case 'daily':
      default:
        return 'Harian (Setiap Hari)';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'is_enabled': isEnabled,
      'frequency': frequency,
      'hour': hour,
      'minute': minute,
      'backup_to_local': backupToLocal,
      'backup_to_cloud': backupToCloud,
      'last_backup_at': lastBackupAt?.toIso8601String(),
      'last_status': lastStatus,
      'last_error_message': lastErrorMessage,
    };
  }

  factory ScheduledBackupConfig.fromMap(Map<String, dynamic> map) {
    return ScheduledBackupConfig(
      isEnabled: map['is_enabled'] as bool? ?? true,
      frequency: map['frequency'] as String? ?? 'daily',
      hour: (map['hour'] as num?)?.toInt() ?? 22,
      minute: (map['minute'] as num?)?.toInt() ?? 0,
      backupToLocal: map['backup_to_local'] as bool? ?? true,
      backupToCloud: map['backup_to_cloud'] as bool? ?? true,
      lastBackupAt: map['last_backup_at'] != null ? DateTime.tryParse(map['last_backup_at'] as String) : null,
      lastStatus: map['last_status'] as String?,
      lastErrorMessage: map['last_error_message'] as String?,
    );
  }

  ScheduledBackupConfig copyWith({
    bool? isEnabled,
    String? frequency,
    int? hour,
    int? minute,
    bool? backupToLocal,
    bool? backupToCloud,
    DateTime? lastBackupAt,
    String? lastStatus,
    String? lastErrorMessage,
  }) {
    return ScheduledBackupConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      frequency: frequency ?? this.frequency,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      backupToLocal: backupToLocal ?? this.backupToLocal,
      backupToCloud: backupToCloud ?? this.backupToCloud,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      lastStatus: lastStatus ?? this.lastStatus,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }
}

