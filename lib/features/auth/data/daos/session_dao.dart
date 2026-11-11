import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class SessionDao {
  static const String activeUserIdKey = 'active_user_id';
  final Database Function() _getDatabase;

  SessionDao(this._getDatabase);

  Future<String?> getActiveUserId() async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.appSettings,
      where: '${DatabaseTables.columnSettingKey} = ?',
      whereArgs: [activeUserIdKey],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first[DatabaseTables.columnSettingValue] as String?;
  }

  Future<void> setActiveUserId(String? userId, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    if (userId == null) {
      await executor.delete(
        DatabaseTables.appSettings,
        where: '${DatabaseTables.columnSettingKey} = ?',
        whereArgs: [activeUserIdKey],
      );
    } else {
      await executor.insert(
        DatabaseTables.appSettings,
        {
          DatabaseTables.columnSettingKey: activeUserIdKey,
          DatabaseTables.columnSettingValue: userId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
