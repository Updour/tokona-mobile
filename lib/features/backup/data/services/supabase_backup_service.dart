import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/backup/domain/models/cloud_backup_model.dart';

class SupabaseBackupService {
  SupabaseBackupService._();

  // Supabase IPv4 Pooler (ap-south-1 Mumbai region)
  static const String poolerHost = 'aws-0-ap-south-1.pooler.supabase.com';
  static const String poolerUsername = 'postgres.gjgfdwzqjypzalzleqgt';

  // Direct Host (IPv6)
  static const String directHost = 'db.gjgfdwzqjypzalzleqgt.supabase.co';
  static const String directUsername = 'postgres';

  static const String database = 'postgres';
  static const String password = 'siffpdzueridtaquvpml';

  static const List<String> _trackedTables = [
    'stores',
    'users',
    'products',
    'product_units',
    'product_price_tiers',
    'suppliers',
    'customers',
    'categories',
    'product_types',
    'sessions',
    'purchases',
    'purchase_items',
    'sales',
    'sale_items',
    'stock_mutations',
    'store_capitals',
    'customer_receivable_payments',
    'devices',
    'payment_accounts',
  ];

  static Future<Connection> _connect() async {
    Object? lastError;

    // 1. Try IPv4 Pooler Session Mode (Port 5432)
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
          connectTimeout: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      lastError = e;
    }

    // 2. Try IPv4 Pooler Transaction Mode (Port 6543)
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
          connectTimeout: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      lastError = e;
    }

    // 3. Fallback to Direct Host (Port 5432)
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
          connectTimeout: Duration(seconds: 12),
        ),
      );
    } catch (e) {
      throw StateError('Gagal terhubung ke database Supabase: ${lastError ?? e}');
    }
  }

  static Future<void> _ensureSchema(Connection conn) async {
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS tokona_cloud_backups (
        id TEXT PRIMARY KEY,
        store_id TEXT NOT NULL,
        store_name TEXT NOT NULL,
        backup_name TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        total_records INTEGER NOT NULL DEFAULT 0,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      )
    ''');
    try {
      await conn.execute('''
        CREATE INDEX IF NOT EXISTS idx_tokona_cloud_backups_store ON tokona_cloud_backups(store_id)
      ''');
    } catch (_) {}
  }

  static Future<CloudBackupModel> createCloudBackup({
    required String storeId,
    required String storeName,
  }) async {
    final db = await AppDatabase.instance.database;
    final Map<String, dynamic> snapshot = {};
    int totalRecords = 0;

    for (final table in _trackedTables) {
      try {
        final rows = await db.query(table);
        snapshot[table] = rows;
        totalRecords += rows.length;
      } catch (_) {
        snapshot[table] = [];
      }
    }

    final payloadJson = jsonEncode(snapshot);
    final sizeInBytes = utf8.encode(payloadJson).length;
    final now = DateTime.now();
    final backupId = IdGenerator.generateId();
    final backupName = 'Cloud Backup ${DateFormat("dd MMM yyyy, HH:mm", "id_ID").format(now)}';

    final conn = await _connect();
    try {
      await _ensureSchema(conn);
      await conn.execute(
        Sql.named('''
          INSERT INTO tokona_cloud_backups (id, store_id, store_name, backup_name, payload_json, total_records, size_bytes, created_at)
          VALUES (@id, @store_id, @store_name, @backup_name, @payload_json, @total_records, @size_bytes, NOW())
        '''),
        parameters: {
          'id': backupId,
          'store_id': storeId,
          'store_name': storeName,
          'backup_name': backupName,
          'payload_json': payloadJson,
          'total_records': totalRecords,
          'size_bytes': sizeInBytes,
        },
      );

      return CloudBackupModel(
        id: backupId,
        storeId: storeId,
        storeName: storeName,
        backupName: backupName,
        totalRecords: totalRecords,
        sizeInBytes: sizeInBytes,
        createdAt: now,
      );
    } finally {
      await conn.close();
    }
  }

  static Future<List<CloudBackupModel>> getCloudBackups(String storeId) async {
    final conn = await _connect();
    try {
      await _ensureSchema(conn);
      final result = await conn.execute(
        Sql.named('''
          SELECT id, store_id, store_name, backup_name, total_records, size_bytes, created_at
          FROM tokona_cloud_backups
          WHERE store_id = @store_id
          ORDER BY created_at DESC
          LIMIT 25
        '''),
        parameters: {'store_id': storeId},
      );

      final List<CloudBackupModel> list = [];
      for (final row in result) {
        final map = <String, dynamic>{
          'id': row[0],
          'store_id': row[1],
          'store_name': row[2],
          'backup_name': row[3],
          'total_records': row[4],
          'size_bytes': row[5],
          'created_at': row[6],
        };
        list.add(CloudBackupModel.fromRow(map));
      }
      return list;
    } finally {
      await conn.close();
    }
  }

  static Future<void> restoreCloudBackup(String backupId) async {
    final conn = await _connect();
    String? payloadJson;
    try {
      final result = await conn.execute(
        Sql.named('SELECT payload_json FROM tokona_cloud_backups WHERE id = @id LIMIT 1'),
        parameters: {'id': backupId},
      );
      if (result.isNotEmpty) {
        payloadJson = result.first[0] as String?;
      }
    } finally {
      await conn.close();
    }

    if (payloadJson == null || payloadJson.isEmpty) {
      throw StateError('Data berkas cadangan di Cloud tidak ditemukan');
    }

    final Map<String, dynamic> snapshot = jsonDecode(payloadJson) as Map<String, dynamic>;
    final db = await AppDatabase.instance.database;

    await db.transaction((txn) async {
      for (final table in _trackedTables.reversed) {
        try {
          await txn.delete(table);
        } catch (_) {}
      }

      for (final table in _trackedTables) {
        final rows = snapshot[table];
        if (rows is List) {
          for (final row in rows) {
            if (row is Map<String, dynamic>) {
              try {
                await txn.insert(table, row);
              } catch (_) {}
            }
          }
        }
      }
    });
  }

  static Future<void> deleteCloudBackup(String backupId) async {
    final conn = await _connect();
    try {
      await conn.execute(
        Sql.named('DELETE FROM tokona_cloud_backups WHERE id = @id'),
        parameters: {'id': backupId},
      );
    } finally {
      await conn.close();
    }
  }

  static Future<bool> testConnection() async {
    try {
      final conn = await _connect();
      await conn.close();
      return true;
    } catch (_) {
      return false;
    }
  }
}

