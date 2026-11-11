import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';

class UserSchema {
  UserSchema._();

  static const String createTableQuery = '''
    CREATE TABLE IF NOT EXISTS ${DatabaseTables.users} (
      ${DatabaseTables.columnId} TEXT PRIMARY KEY,
      ${DatabaseTables.columnUserStoreId} TEXT NOT NULL,
      ${DatabaseTables.columnUserUsername} TEXT NOT NULL UNIQUE,
      ${DatabaseTables.columnUserFullName} TEXT NOT NULL,
      ${DatabaseTables.columnUserPasswordHash} TEXT NOT NULL,
      ${DatabaseTables.columnUserSalt} TEXT NOT NULL,
      ${DatabaseTables.columnUserRole} TEXT NOT NULL,
      ${DatabaseTables.columnUserIsActive} INTEGER NOT NULL DEFAULT 1,
      ${DatabaseTables.columnCreatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnUpdatedAt} TEXT NOT NULL,
      ${DatabaseTables.columnSyncedAt} TEXT,
      FOREIGN KEY (${DatabaseTables.columnUserStoreId})
        REFERENCES ${DatabaseTables.stores} (${DatabaseTables.columnId})
        ON DELETE CASCADE
    );
  ''';

  static const String createUsernameIndex = '''
    CREATE INDEX IF NOT EXISTS idx_users_username
    ON ${DatabaseTables.users} (${DatabaseTables.columnUserUsername});
  ''';

  static const String createStoreIndex = '''
    CREATE INDEX IF NOT EXISTS idx_users_store_id
    ON ${DatabaseTables.users} (${DatabaseTables.columnUserStoreId});
  ''';

  static Future<void> create(Database db) async {
    await db.execute(createTableQuery);
    await db.execute(createUsernameIndex);
    await db.execute(createStoreIndex);
  }
}
