import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/core/utils/password_hasher.dart';
import 'package:tokona/features/auth/data/daos/session_dao.dart';
import 'package:tokona/features/auth/data/daos/store_dao.dart';
import 'package:tokona/features/auth/data/daos/user_dao.dart';
import 'package:tokona/features/auth/domain/dtos/login_dto.dart';
import 'package:tokona/features/auth/domain/dtos/register_dto.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';

class AuthRepository {
  final AppDatabase _appDatabase;
  late final StoreDao _storeDao;
  late final UserDao _userDao;
  late final SessionDao _sessionDao;
  Database? _db;

  AuthRepository(this._appDatabase) {
    _storeDao = StoreDao(() => _db!);
    _userDao = UserDao(() => _db!);
    _sessionDao = SessionDao(() => _db!);
  }

  Future<void> initialize() async {
    _db = await _appDatabase.database;
  }

  Future<bool> hasRegisteredStore() async {
    await initialize();
    final count = await _storeDao.countStores();
    return count > 0;
  }

  Future<StoreModel?> getActiveStore() async {
    await initialize();
    return await _storeDao.getFirstStore();
  }

  Future<({StoreModel store, UserModel user})?> getActiveSession() async {
    await initialize();
    final activeUserId = await _sessionDao.getActiveUserId();
    if (activeUserId == null) return null;

    final user = await _userDao.findById(activeUserId);
    if (user == null || !user.isActive) {
      await _sessionDao.setActiveUserId(null);
      return null;
    }

    final store = await _storeDao.getStoreById(user.storeId);
    if (store == null) {
      await _sessionDao.setActiveUserId(null);
      return null;
    }

    return (store: store, user: user);
  }

  Future<void> clearSession() async {
    await initialize();
    await _sessionDao.setActiveUserId(null);
  }

  Future<({StoreModel store, UserModel user})> registerStoreAndOwner(RegisterDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final existingUser = await _userDao.findByUsername(dto.username);
    if (existingUser != null) {
      throw StateError('Nama pengguna sudah terdaftar');
    }

    final now = DateTime.now();
    final storeId = IdGenerator.generateId(prefix: 'STR');
    final userId = IdGenerator.generateId(prefix: 'USR');
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hashPassword(dto.password, salt);

    final store = StoreModel(
      id: storeId,
      name: dto.storeName.trim(),
      address: dto.storeAddress?.trim(),
      phone: dto.storePhone?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final user = UserModel(
      id: userId,
      storeId: storeId,
      username: dto.username.trim(),
      fullName: dto.ownerFullName.trim(),
      passwordHash: passwordHash,
      salt: salt,
      role: UserRole.owner,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await _db!.transaction((txn) async {
      await _storeDao.insertStore(store, txn: txn);
      await _userDao.insertUser(user, txn: txn);
      await _sessionDao.setActiveUserId(user.id, txn: txn);
    });

    return (store: store, user: user);
  }

  Future<({StoreModel store, UserModel user})> login(LoginDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final user = await _userDao.findByUsername(dto.username);
    if (user == null) {
      throw StateError('Nama pengguna atau kata sandi tidak valid');
    }

    if (!user.isActive) {
      throw StateError('Akun pengguna berstatus nonaktif');
    }

    final isPasswordValid = PasswordHasher.verifyPassword(
      password: dto.password,
      salt: user.salt,
      expectedHash: user.passwordHash,
    );

    if (!isPasswordValid) {
      throw StateError('Nama pengguna atau kata sandi tidak valid');
    }

    final store = await _storeDao.getStoreById(user.storeId);
    if (store == null) {
      throw StateError('Data toko untuk pengguna ini tidak ditemukan');
    }

    await _sessionDao.setActiveUserId(user.id);

    return (store: store, user: user);
  }

  Future<StoreModel> updateStore(StoreModel store) async {
    await initialize();
    final updatedStore = store.copyWith(updatedAt: DateTime.now());
    await _storeDao.updateStore(updatedStore);
    return updatedStore;
  }

  Future<UserModel?> findUserByUsername(String username) async {
    await initialize();
    return await _userDao.findByUsername(username);
  }

  Future<void> resetPassword({
    required String username,
    required String newPassword,
  }) async {
    await initialize();
    final user = await _userDao.findByUsername(username);
    if (user == null) {
      throw StateError('Pengguna dengan nama tersebut tidak ditemukan');
    }
    if (newPassword.length < 6) {
      throw ArgumentError('Kata sandi minimal 6 karakter');
    }
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hashPassword(newPassword, salt);
    await _userDao.updatePassword(user.id, passwordHash, salt);
  }

  Future<List<UserModel>> getStoreUsers(String storeId) async {
    await initialize();
    return await _userDao.getUsersByStoreId(storeId);
  }

  Future<UserModel> createStaffUser({
    required String storeId,
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    await initialize();
    final existing = await _userDao.findByUsername(username);
    if (existing != null) {
      throw StateError('Username $username sudah digunakan');
    }
    if (password.length < 6) {
      throw ArgumentError('Kata sandi minimal 6 karakter');
    }

    final now = DateTime.now();
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hashPassword(password, salt);
    final user = UserModel(
      id: IdGenerator.generateId(prefix: 'USR'),
      storeId: storeId,
      username: username.trim(),
      fullName: fullName.trim(),
      passwordHash: hash,
      salt: salt,
      role: role,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    await _userDao.insertUser(user);
    return user;
  }

  Future<void> deleteStaffUser(String userId) async {
    await initialize();
    await _userDao.deleteUser(userId);
  }

  Future<({StoreModel store, UserModel user})> importPairingData(Map<String, dynamic> data) async {
    await initialize();
    final store = StoreModel(
      id: data['store_id'] as String,
      name: (data['store_name'] as String?) ?? 'Tokona Store',
      address: data['store_address'] as String?,
      phone: data['store_phone'] as String?,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final user = UserModel(
      id: data['user_id'] as String? ?? IdGenerator.generateId(prefix: 'USR'),
      storeId: store.id,
      username: data['username'] as String,
      fullName: (data['full_name'] as String?) ?? data['username'] as String,
      passwordHash: data['password_hash'] as String,
      salt: data['salt'] as String,
      role: UserRole.fromString((data['role'] as String?) ?? 'cashier'),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _db!.transaction((txn) async {
      await _storeDao.insertStore(store, txn: txn);
      await _userDao.insertUser(user, txn: txn);
      await _sessionDao.setActiveUserId(user.id, txn: txn);
    });

    return (store: store, user: user);
  }

  Future<({StoreModel store, UserModel user})> registerCashierFromInvite({
    required Map<String, dynamic> storeData,
    required String fullName,
    required String username,
    required String password,
  }) async {
    await initialize();
    final store = StoreModel(
      id: storeData['store_id'] as String, name: (storeData['store_name'] as String?) ?? 'Tokona Store',
      address: storeData['store_address'] as String?, phone: storeData['store_phone'] as String?,
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hashPassword(password, salt);

    final user = UserModel(
      id: IdGenerator.generateId(prefix: 'USR'), storeId: store.id,
      username: username.trim().toLowerCase(), fullName: fullName.trim(),
      passwordHash: hash, salt: salt, role: UserRole.cashier,
      isActive: true, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    await _db!.transaction((txn) async {
      await _storeDao.insertStore(store, txn: txn);
      await _userDao.insertUser(user, txn: txn);
      await _sessionDao.setActiveUserId(user.id, txn: txn);
    });

    return (store: store, user: user);
  }
}
