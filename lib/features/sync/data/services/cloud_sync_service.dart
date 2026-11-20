import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';

class SyncResult {
  final int uploadedCount;
  final int downloadedCount;
  final int remainingPending;

  const SyncResult({
    required this.uploadedCount,
    required this.downloadedCount,
    required this.remainingPending,
  });
}

class CloudSyncService {
  CloudSyncService._();

  static const String poolerHost = 'aws-0-ap-south-1.pooler.supabase.com';
  static const String poolerUsername = 'postgres.gjgfdwzqjypzalzleqgt';
  static const String directHost = 'db.gjgfdwzqjypzalzleqgt.supabase.co';
  static const String directUsername = 'postgres';
  static const String database = 'postgres';
  static const String password = 'siffpdzueridtaquvpml';

  static const List<String> _syncableTables = [
    'products',
    'product_units',
    'product_price_tiers',
    'customers',
    'sales',
    'purchases',
    'suppliers',
  ];

  static Future<bool> _hasSyncedAt(Database db, String table) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info($table)');
      return info.any((col) => col['name'] == DatabaseTables.columnSyncedAt);
    } catch (_) {
      return false;
    }
  }

  static Future<Connection> _connect() async {
    Object? lastErr;
    try {
      return await Connection.open(
        Endpoint(
          host: poolerHost,
          port: 5432,
          database: database,
          username: poolerUsername,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      lastErr = e;
    }

    try {
      return await Connection.open(
        Endpoint(
          host: poolerHost,
          port: 6543,
          database: database,
          username: poolerUsername,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      lastErr = e;
    }

    try {
      return await Connection.open(
        Endpoint(
          host: directHost,
          port: 5432,
          database: database,
          username: directUsername,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      throw StateError('Koneksi Cloud Database gagal: $lastErr');
    }
  }

  static Future<void> _ensureSchema(Connection conn) async {
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS tokona_entity_sync (
        id TEXT PRIMARY KEY,
        store_id TEXT NOT NULL,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        device_tag TEXT,
        synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      )
    ''');
    try {
      await conn.execute('''
        CREATE INDEX IF NOT EXISTS idx_tokona_sync_lookup 
        ON tokona_entity_sync(store_id, table_name, synced_at)
      ''');
    } catch (_) {}
  }

  static Future<int> countPendingRecords(String storeId) async {
    final db = await AppDatabase.instance.database;
    int pending = 0;

    for (final table in _syncableTables) {
      if (!await _hasSyncedAt(db, table)) continue;
      try {
        final res = await db.rawQuery(
          'SELECT COUNT(*) as c FROM $table WHERE ${DatabaseTables.columnSyncedAt} IS NULL OR ${DatabaseTables.columnSyncedAt} = ""',
        );
        pending += (Sqflite.firstIntValue(res) ?? 0);
      } catch (_) {}
    }
    return pending;
  }

  static Future<SyncResult> performSync({
    required String storeId,
    required String deviceTag,
    DateTime? lastPullTime,
  }) async {
    final conn = await _connect();
    final db = await AppDatabase.instance.database;

    try {
      await _ensureSchema(conn);

      // 1. PUSH: Kirim data lokal yang belum tersinkron
      int uploaded = 0;
      final nowIso = DateTime.now().toIso8601String();

      for (final table in _syncableTables) {
        if (!await _hasSyncedAt(db, table)) continue;
        try {
          final unsynced = await db.query(
            table,
            where: '${DatabaseTables.columnSyncedAt} IS NULL OR ${DatabaseTables.columnSyncedAt} = ""',
            limit: 100,
          );

          for (final row in unsynced) {
            final recordId = row['id']?.toString() ?? '';
            if (recordId.isEmpty) continue;

            final syncRecordId = '${table}_$recordId';
            final payloadJson = jsonEncode(row);

          await conn.execute(
            Sql.named('''
              INSERT INTO tokona_entity_sync (id, store_id, table_name, record_id, payload_json, device_tag, synced_at)
              VALUES (@id, @store_id, @table_name, @record_id, @payload_json, @device_tag, NOW())
              ON CONFLICT (id) DO UPDATE SET 
                payload_json = EXCLUDED.payload_json,
                device_tag = EXCLUDED.device_tag,
                synced_at = NOW()
            '''),
            parameters: {
              'id': syncRecordId,
              'store_id': storeId,
              'table_name': table,
              'record_id': recordId,
              'payload_json': payloadJson,
              'device_tag': deviceTag,
            },
          );

          await db.update(
            table,
            {DatabaseTables.columnSyncedAt: nowIso},
            where: 'id = ?',
            whereArgs: [recordId],
          );
          uploaded++;
        }
      } catch (_) {}
    }

      // 2. PULL: Tarik data terbaru dari Cloud (dibuat oleh perangkat lain)
      int downloaded = 0;
      final pullParams = <String, dynamic>{'store_id': storeId};
      String pullSql = '''
        SELECT id, table_name, record_id, payload_json, device_tag, synced_at
        FROM tokona_entity_sync
        WHERE store_id = @store_id
      ''';

      if (lastPullTime != null) {
        pullSql += ' AND synced_at > @last_pull';
        pullParams['last_pull'] = lastPullTime;
      }
      pullSql += ' ORDER BY synced_at ASC LIMIT 200';

      final remoteRows = await conn.execute(Sql.named(pullSql), parameters: pullParams);

      for (final r in remoteRows) {
        final tableName = r[1] as String;
        final payloadJson = r[3] as String;
        final originDevice = r[4] as String?;

        if (originDevice == deviceTag) continue; // Lewati jika berasal dari HP ini sendiri

        try {
          final map = jsonDecode(payloadJson) as Map<String, dynamic>;
          map['synced_at'] = nowIso;

          await db.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          downloaded++;
        } catch (_) {}
      }

      final remaining = await countPendingRecords(storeId);
      return SyncResult(
        uploadedCount: uploaded,
        downloadedCount: downloaded,
        remainingPending: remaining,
      );
    } finally {
      await conn.close();
    }
  }
}
