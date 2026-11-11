import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';

class DeviceDao {
  const DeviceDao();

  static const List<String> initialDefaults = [
    'HP 1',
    'HP 2',
    'HP 3',
  ];

  Future<List<String>> getDevices(DatabaseExecutor db, String storeId) async {
    final rows = await db.query(
      DatabaseTables.devices,
      columns: [DatabaseTables.columnDeviceName],
      where: '${DatabaseTables.columnDeviceStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnCreatedAt} ASC',
    );

    if (rows.isEmpty) {
      final now = DateTime.now();
      for (int i = 0; i < initialDefaults.length; i++) {
        final devName = initialDefaults[i];
        final id = IdGenerator.generateId(prefix: 'DEV');
        await db.insert(
          DatabaseTables.devices,
          {
            DatabaseTables.columnId: id,
            DatabaseTables.columnDeviceStoreId: storeId,
            DatabaseTables.columnDeviceName: devName,
            DatabaseTables.columnCreatedAt: now.add(Duration(seconds: i)).toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      return List<String>.from(initialDefaults);
    }

    return rows.map((r) => r[DatabaseTables.columnDeviceName] as String).toList();
  }

  Future<void> addDevice(DatabaseExecutor db, String storeId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final existing = await db.query(
      DatabaseTables.devices,
      where: '${DatabaseTables.columnDeviceStoreId} = ? AND LOWER(${DatabaseTables.columnDeviceName}) = ?',
      whereArgs: [storeId, trimmed.toLowerCase()],
      limit: 1,
    );

    if (existing.isNotEmpty) return;

    final id = IdGenerator.generateId(prefix: 'DEV');
    final now = DateTime.now().toIso8601String();

    await db.insert(
      DatabaseTables.devices,
      {
        DatabaseTables.columnId: id,
        DatabaseTables.columnDeviceStoreId: storeId,
        DatabaseTables.columnDeviceName: trimmed,
        DatabaseTables.columnCreatedAt: now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDevice(DatabaseExecutor db, String storeId, String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await db.update(
      DatabaseTables.devices,
      {DatabaseTables.columnDeviceName: trimmed},
      where: '${DatabaseTables.columnDeviceStoreId} = ? AND ${DatabaseTables.columnDeviceName} = ?',
      whereArgs: [storeId, oldName],
    );
  }

  Future<void> deleteDevice(DatabaseExecutor db, String storeId, String name) async {
    await db.delete(
      DatabaseTables.devices,
      where: '${DatabaseTables.columnDeviceStoreId} = ? AND ${DatabaseTables.columnDeviceName} = ?',
      whereArgs: [storeId, name],
    );
  }
}
