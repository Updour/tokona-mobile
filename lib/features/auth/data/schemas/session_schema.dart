import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class SessionSchema {
  SessionSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.appSettings} (
      ${DatabaseTables.columnSettingKey} TEXT PRIMARY KEY,
      ${DatabaseTables.columnSettingValue} TEXT
    );
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
  }
}
