import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:postgres/postgres.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/settings/domain/models/audit_log_model.dart';
import 'package:tokona/features/sync/data/services/cloud_sync_service.dart';

class AuditLogService {
  AuditLogService._();

  static const String _fileName = 'tokona_audit_logs.json';

  static Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, _fileName));
  }

  static Future<List<AuditLogModel>> getLogs({AuditActionType? filterType}) async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      // Hapus data dummy jika ada
      final logs = list
          .map((e) => AuditLogModel.fromMap(e as Map<String, dynamic>))
          .where((l) => !l.id.startsWith('LOG-INIT-'))
          .toList();

      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (filterType != null) {
        return logs.where((l) => l.actionType == filterType).toList();
      }
      return logs;
    } catch (_) {
      return [];
    }
  }

  static Future<void> log({
    required String storeId,
    required String userId,
    required String userName,
    required String userRole,
    required AuditActionType actionType,
    required String title,
    required String description,
    String? deviceTag,
  }) async {
    try {
      final logs = await getLogs();
      final newLog = AuditLogModel(
        id: IdGenerator.generateId(prefix: 'LOG'),
        storeId: storeId,
        userId: userId,
        userName: userName,
        userRole: userRole,
        actionType: actionType,
        title: title,
        description: description,
        timestamp: DateTime.now(),
        deviceTag: deviceTag,
      );
      logs.insert(0, newLog);
      final trimmed = logs.take(300).toList();
      await _saveLogs(trimmed);

      // Otomatis push ke Cloud Supabase di background
      _pushSingleLogToCloud(newLog);
    } catch (_) {}
  }

  static Future<void> _saveLogs(List<AuditLogModel> logs) async {
    final file = await _getFile();
    final jsonString = jsonEncode(logs.map((l) => l.toMap()).toList());
    await file.writeAsString(jsonString);
  }

  static Future<Connection> _connect() async {
    try {
      return await Connection.open(
        Endpoint(
          host: CloudSyncService.poolerHost,
          port: 5432,
          database: CloudSyncService.database,
          username: CloudSyncService.poolerUsername,
          password: CloudSyncService.password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return await Connection.open(
        Endpoint(
          host: CloudSyncService.directHost,
          port: 5432,
          database: CloudSyncService.database,
          username: CloudSyncService.directUsername,
          password: CloudSyncService.password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 8),
        ),
      );
    }
  }

  static Future<void> _pushSingleLogToCloud(AuditLogModel log) async {
    try {
      final conn = await _connect();
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS tokona_audit_sync (
            id TEXT PRIMARY KEY,
            store_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            user_name TEXT NOT NULL,
            user_role TEXT NOT NULL,
            action_type TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
            device_tag TEXT
          )
        ''');

        await conn.execute(
          Sql.named('''
            INSERT INTO tokona_audit_sync (id, store_id, user_id, user_name, user_role, action_type, title, description, timestamp, device_tag)
            VALUES (@id, @store_id, @user_id, @user_name, @user_role, @action_type, @title, @description, @timestamp, @device_tag)
            ON CONFLICT (id) DO NOTHING
          '''),
          parameters: {
            'id': log.id,
            'store_id': log.storeId,
            'user_id': log.userId,
            'user_name': log.userName,
            'user_role': log.userRole,
            'action_type': log.actionType.key,
            'title': log.title,
            'description': log.description,
            'timestamp': log.timestamp,
            'device_tag': log.deviceTag,
          },
        );
      } finally {
        await conn.close();
      }
    } catch (_) {}
  }

  static Future<int> syncCloudLogs(String storeId) async {
    try {
      final conn = await _connect();
      try {
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS tokona_audit_sync (
            id TEXT PRIMARY KEY,
            store_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            user_name TEXT NOT NULL,
            user_role TEXT NOT NULL,
            action_type TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
            device_tag TEXT
          )
        ''');

        // 1. Tarik log terbaru dari Cloud Supabase
        final rows = await conn.execute(
          Sql.named('''
            SELECT id, store_id, user_id, user_name, user_role, action_type, title, description, timestamp, device_tag
            FROM tokona_audit_sync
            WHERE store_id = @store_id
            ORDER BY timestamp DESC LIMIT 200
          '''),
          parameters: {'store_id': storeId},
        );

        final localLogs = await getLogs();
        final localIds = localLogs.map((e) => e.id).toSet();
        int newDownloaded = 0;

        for (final r in rows) {
          final id = r[0] as String;
          if (!localIds.contains(id)) {
            final cloudLog = AuditLogModel(
              id: id,
              storeId: r[1] as String,
              userId: r[2] as String,
              userName: r[3] as String,
              userRole: r[4] as String,
              actionType: AuditActionType.fromKey(r[5] as String),
              title: r[6] as String,
              description: r[7] as String,
              timestamp: r[8] as DateTime,
              deviceTag: r[9] as String?,
            );
            localLogs.add(cloudLog);
            localIds.add(id);
            newDownloaded++;
          }
        }

        // 2. Upload log lokal yang belum ada di Cloud
        for (final l in localLogs) {
          try {
            await conn.execute(
              Sql.named('''
                INSERT INTO tokona_audit_sync (id, store_id, user_id, user_name, user_role, action_type, title, description, timestamp, device_tag)
                VALUES (@id, @store_id, @user_id, @user_name, @user_role, @action_type, @title, @description, @timestamp, @device_tag)
                ON CONFLICT (id) DO NOTHING
              '''),
              parameters: {
                'id': l.id,
                'store_id': l.storeId,
                'user_id': l.userId,
                'user_name': l.userName,
                'user_role': l.userRole,
                'action_type': l.actionType.key,
                'title': l.title,
                'description': l.description,
                'timestamp': l.timestamp,
                'device_tag': l.deviceTag,
              },
            );
          } catch (_) {}
        }

        localLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        await _saveLogs(localLogs.take(300).toList());
        return newDownloaded;
      } finally {
        await conn.close();
      }
    } catch (_) {
      return 0;
    }
  }
}
