import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/features/backup/domain/models/backup_file_model.dart';

class BackupService {
  BackupService._();

  static Future<Directory> _getBackupDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docsDir.path, 'tokona_backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  static Future<File> _getActiveDatabaseFile() async {
    final dbDir = await getDatabasesPath();
    return File(p.join(dbDir, AppDatabase.databaseName));
  }

  static Future<BackupFileModel> createBackup() async {
    final activeDbFile = await _getActiveDatabaseFile();
    if (!await activeDbFile.exists()) {
      throw StateError('Database aktif belum ditemukan');
    }

    final backupDir = await _getBackupDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'tokona_backup_$timestamp.db';
    final targetFile = File(p.join(backupDir.path, backupFileName));

    await activeDbFile.copy(targetFile.path);

    final stat = await targetFile.stat();
    return BackupFileModel(
      path: targetFile.path,
      fileName: backupFileName,
      sizeInBytes: stat.size,
      createdAt: DateTime.now(),
    );
  }

  static Future<List<BackupFileModel>> getBackupList() async {
    final backupDir = await _getBackupDirectory();
    final entities = await backupDir.list().toList();

    final List<BackupFileModel> backups = [];
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.db')) {
        final stat = await entity.stat();
        backups.add(
          BackupFileModel(
            path: entity.path,
            fileName: p.basename(entity.path),
            sizeInBytes: stat.size,
            createdAt: stat.modified,
          ),
        );
      }
    }

    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  static Future<void> restoreBackup(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) {
      throw StateError('Berkas cadangan tidak ditemukan');
    }

    final activeDbFile = await _getActiveDatabaseFile();

    // 1. Tutup koneksi database saat ini
    await AppDatabase.instance.close();

    // 2. Timpa file database dengan cadangan
    await backupFile.copy(activeDbFile.path);

    // 3. Re-inisialisasi database
    await AppDatabase.instance.initDatabase();
  }

  static Future<void> deleteBackup(String backupFilePath) async {
    final file = File(backupFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<Map<String, dynamic>> getStorageSummary() async {
    final activeDbFile = await _getActiveDatabaseFile();
    int activeDbSize = 0;
    if (await activeDbFile.exists()) {
      final stat = await activeDbFile.stat();
      activeDbSize = stat.size;
    }

    final backups = await getBackupList();
    int totalBackupSize = 0;
    for (final b in backups) {
      totalBackupSize += b.sizeInBytes;
    }

    return {
      'activeDbSize': activeDbSize,
      'backupCount': backups.length,
      'totalBackupSize': totalBackupSize,
      'dbPath': activeDbFile.path,
    };
  }
}

