import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/core/utils/password_hasher.dart';
import 'package:tokona/features/auth/domain/dtos/login_dto.dart';
import 'package:tokona/features/auth/domain/dtos/register_dto.dart';
import 'package:tokona/features/auth/domain/models/store_model.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';

void main() {
  group('PasswordHasher', () {
    test('generates unique salts and verifies matching hash', () {
      final salt1 = PasswordHasher.generateSalt();
      final salt2 = PasswordHasher.generateSalt();

      expect(salt1, isNotEmpty);
      expect(salt2, isNotEmpty);
      expect(salt1 != salt2, isTrue);

      const password = 'mySecretPassword123';
      final hash = PasswordHasher.hashPassword(password, salt1);

      expect(
        PasswordHasher.verifyPassword(
          password: password,
          salt: salt1,
          expectedHash: hash,
        ),
        isTrue,
      );

      expect(
        PasswordHasher.verifyPassword(
          password: 'wrongPassword',
          salt: salt1,
          expectedHash: hash,
        ),
        isFalse,
      );
    });
  });

  group('IdGenerator', () {
    test('generates non-empty unique identifiers with optional prefix', () {
      final id1 = IdGenerator.generateId(prefix: 'STR');
      final id2 = IdGenerator.generateId(prefix: 'STR');

      expect(id1.startsWith('STR-'), isTrue);
      expect(id2.startsWith('STR-'), isTrue);
      expect(id1 != id2, isTrue);
    });
  });

  group('DTO Validation', () {
    test('RegisterDto validates required fields and length', () {
      const invalidDto = RegisterDto(
        storeName: '',
        ownerFullName: '',
        username: 'ab',
        password: '123',
      );
      expect(invalidDto.validate(), isNotNull);

      const validDto = RegisterDto(
        storeName: 'Toko Makmur',
        ownerFullName: 'Budi Santoso',
        username: 'budi_owner',
        password: 'secretPassword123',
      );
      expect(validDto.validate(), isNull);
    });

    test('LoginDto validates empty credentials', () {
      const emptyDto = LoginDto(username: '', password: '');
      expect(emptyDto.validate(), isNotNull);

      const validDto = LoginDto(username: 'admin', password: 'secretPassword');
      expect(validDto.validate(), isNull);
    });
  });

  group('UserModel and StoreModel', () {
    test('StoreModel serializes and deserializes accurately', () {
      final now = DateTime.now();
      final store = StoreModel(
        id: 'STR-001',
        name: 'Toko Sumber Rezeki',
        phone: '08123456789',
        address: 'Jl. Merdeka No. 10',
        createdAt: now,
        updatedAt: now,
      );

      final map = store.toMap();
      final deserialized = StoreModel.fromMap(map);

      expect(deserialized.id, store.id);
      expect(deserialized.name, store.name);
      expect(deserialized.phone, store.phone);
    });

    test('UserModel role permissions are enforced', () {
      final now = DateTime.now();
      final owner = UserModel(
        id: 'USR-001',
        storeId: 'STR-001',
        username: 'owner1',
        fullName: 'Owner Toko',
        passwordHash: 'hash',
        salt: 'salt',
        role: UserRole.owner,
        createdAt: now,
        updatedAt: now,
      );

      final cashier = UserModel(
        id: 'USR-002',
        storeId: 'STR-001',
        username: 'cashier1',
        fullName: 'Kasir Toko',
        passwordHash: 'hash',
        salt: 'salt',
        role: UserRole.cashier,
        createdAt: now,
        updatedAt: now,
      );

      expect(owner.isOwner, isTrue);
      expect(owner.canManageInventory, isTrue);
      expect(cashier.isOwner, isFalse);
      expect(cashier.canManageInventory, isFalse);
    });
  });
}
