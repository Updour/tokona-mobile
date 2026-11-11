class CloudBackupModel {
  final String id;
  final String storeId;
  final String storeName;
  final String backupName;
  final int totalRecords;
  final int sizeInBytes;
  final DateTime createdAt;

  const CloudBackupModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.backupName,
    required this.totalRecords,
    required this.sizeInBytes,
    required this.createdAt,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  factory CloudBackupModel.fromRow(Map<String, dynamic> row) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CloudBackupModel(
      id: row['id'] as String? ?? '',
      storeId: row['store_id'] as String? ?? '',
      storeName: row['store_name'] as String? ?? 'Tokona Store',
      backupName: row['backup_name'] as String? ?? 'Cloud Backup',
      totalRecords: (row['total_records'] as num?)?.toInt() ?? 0,
      sizeInBytes: (row['size_bytes'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(row['created_at']),
    );
  }
}

