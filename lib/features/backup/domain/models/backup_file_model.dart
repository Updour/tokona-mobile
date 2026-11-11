class BackupFileModel {
  final String path;
  final String fileName;
  final int sizeInBytes;
  final DateTime createdAt;

  const BackupFileModel({
    required this.path,
    required this.fileName,
    required this.sizeInBytes,
    required this.createdAt,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

