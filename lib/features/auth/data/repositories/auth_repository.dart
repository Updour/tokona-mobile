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
}
