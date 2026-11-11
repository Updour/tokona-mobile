import 'package:flutter_test/flutter_test.dart';
import 'package:tokona/features/customer/domain/dtos/create_customer_dto.dart';
import 'package:tokona/features/customer/domain/dtos/update_customer_dto.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';

void main() {
  group('Customer DTO Validations', () {
    test('CreateCustomerDto validates name and phone correctly', () {
      const invalidEmptyName = CreateCustomerDto(name: '');
      expect(invalidEmptyName.validate(), isNotNull);

      const invalidShortName = CreateCustomerDto(name: 'A');
      expect(invalidShortName.validate(), isNotNull);

      const invalidPhone = CreateCustomerDto(name: 'Budi Santoso', phone: '123');
      expect(invalidPhone.validate(), isNotNull);

      const invalidNegativeReceivable = CreateCustomerDto(
        name: 'Budi Santoso',
        initialReceivableBalance: -1000,
      );
      expect(invalidNegativeReceivable.validate(), isNotNull);

      const validDto = CreateCustomerDto(
        name: 'Bu Siti Warung',
        phone: '081234567890',
        customerType: 'member',
        address: 'RT 02 RW 03',
        initialReceivableBalance: 25000,
      );
      expect(validDto.validate(), isNull);
    });

    test('UpdateCustomerDto validates updates properly', () {
      const invalidEmptyUpdate = UpdateCustomerDto(name: '   ');
      expect(invalidEmptyUpdate.validate(), isNotNull);

      const invalidNegReceivable = UpdateCustomerDto(receivableBalance: -500);
      expect(invalidNegReceivable.validate(), isNotNull);

      const validUpdate = UpdateCustomerDto(
        name: 'Toko Berkah Grosir',
        customerType: 'grosir',
        receivableBalance: 150000,
      );
      expect(validUpdate.validate(), isNull);
    });
  });

  group('CustomerModel Tests', () {
    test('serializes and deserializes from/to SQLite Map accurately', () {
      final now = DateTime.now();
      final customer = CustomerModel(
        id: 'CST-TEST-001',
        storeId: 'STR-001',
        name: 'Pak Haji Romli',
        phone: '081987654321',
        address: 'Jl. Melati No. 5',
        customerType: 'grosir',
        notes: 'Langganan beras & minyak',
        receivableBalance: 120000,
        createdAt: now,
        updatedAt: now,
      );

      expect(customer.isGrosir, isTrue);
      expect(customer.isMember, isFalse);
      expect(customer.isUmum, isFalse);
      expect(customer.hasReceivable, isTrue);
      expect(customer.typeLabel, 'Pelanggan Grosir');
      expect(customer.displaySubtitle, '081987654321 • Jl. Melati No. 5');

      final map = customer.toMap();
      final reconstructed = CustomerModel.fromMap(map);

      expect(reconstructed.id, customer.id);
      expect(reconstructed.storeId, customer.storeId);
      expect(reconstructed.name, customer.name);
      expect(reconstructed.phone, customer.phone);
      expect(reconstructed.customerType, customer.customerType);
      expect(reconstructed.receivableBalance, customer.receivableBalance);
    });

    test('correctly identifies member and umum types', () {
      final now = DateTime.now();
      final member = CustomerModel(
        id: 'CST-002',
        storeId: 'STR-001',
        name: 'Mbak Dewi',
        customerType: 'member',
        createdAt: now,
        updatedAt: now,
      );
      expect(member.isMember, isTrue);
      expect(member.typeLabel, 'Member Langganan');

      final umum = CustomerModel(
        id: 'CST-003',
        storeId: 'STR-001',
        name: 'Pelanggan Umum',
        customerType: 'umum',
        createdAt: now,
        updatedAt: now,
      );
      expect(umum.isUmum, isTrue);
      expect(umum.typeLabel, 'Pelanggan Umum');
      expect(umum.hasReceivable, isFalse);
    });
  });
}

