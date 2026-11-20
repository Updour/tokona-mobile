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

  Future<void> updatePassword(String userId, String passwordHash, String salt, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    final nowIso = DateTime.now().toIso8601String();
    await executor.update(
      DatabaseTables.users,
      {
        DatabaseTables.columnUserPasswordHash: passwordHash,
        DatabaseTables.columnUserSalt: salt,
        DatabaseTables.columnUpdatedAt: nowIso,
        DatabaseTables.columnSyncedAt: null,
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [userId],
    );
  }

  Future<int> countUsers() async {
    final db = _getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM ${DatabaseTables.users}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<UserModel>> getUsersByStoreId(String storeId) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.users,
      where: '${DatabaseTables.columnUserStoreId} = ?',
      whereArgs: [storeId],
      orderBy: '${DatabaseTables.columnCreatedAt} ASC',
    );
    return results.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<void> deleteUser(String userId) async {
    final db = _getDatabase();
    await db.delete(
      DatabaseTables.users,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [userId],
    );
  }

  Future<void> toggleUserActive(String userId, bool isActive) async {
    final db = _getDatabase();
    await db.update(
      DatabaseTables.users,
      {
        DatabaseTables.columnUserIsActive: isActive ? 1 : 0,
        DatabaseTables.columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [userId],
    );
  }
}
