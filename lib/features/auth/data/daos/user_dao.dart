import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';

class UserDao {
  final Database Function() _getDatabase;

  UserDao(this._getDatabase);

  Future<void> insertUser(UserModel user, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.users,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> findByUsername(String username) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.users,
      where: 'LOWER(${DatabaseTables.columnUserUsername}) = LOWER(?)',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<UserModel?> findById(String id) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.users,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  Future<int> countUsers() async {
    final db = _getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM ${DatabaseTables.users}');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
