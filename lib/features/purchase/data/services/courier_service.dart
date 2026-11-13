import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';

class CourierService {
  static const String settingKey = 'frequent_couriers';
  static const List<String> defaultCouriers = ['J&T Cargo', 'SPX', 'J&T'];

  static Future<List<String>> getCouriers() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        DatabaseTables.appSettings,
        where: '${DatabaseTables.columnSettingKey} = ?',
        whereArgs: [settingKey],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final val = rows.first[DatabaseTables.columnSettingValue] as String?;
        if (val != null && val.trim().isNotEmpty) {
          final list = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}
    return List.from(defaultCouriers);
  }

  static Future<void> saveCourier(String courier) async {
    final clean = courier.trim();
    if (clean.isEmpty) return;
    try {
      final current = await getCouriers();
      current.removeWhere((c) => c.toLowerCase() == clean.toLowerCase());
      current.insert(0, clean);
      final trimmed = current.take(5).toList();
      final db = await AppDatabase.instance.database;
      await db.insert(
        DatabaseTables.appSettings,
        {
          DatabaseTables.columnSettingKey: settingKey,
          DatabaseTables.columnSettingValue: trimmed.join(','),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  static Future<void> deleteCourier(String courier) async {
    try {
      final current = await getCouriers();
      current.removeWhere((c) => c.toLowerCase() == courier.trim().toLowerCase());
      final db = await AppDatabase.instance.database;
      await db.insert(
        DatabaseTables.appSettings,
        {
          DatabaseTables.columnSettingKey: settingKey,
          DatabaseTables.columnSettingValue: current.join(','),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }
}
