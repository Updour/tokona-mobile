import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/customer/data/daos/customer_dao.dart';
import 'package:tokona/features/customer/data/daos/customer_receivable_payment_dao.dart';
import 'package:tokona/features/customer/domain/dtos/create_customer_dto.dart';
import 'package:tokona/features/customer/domain/dtos/update_customer_dto.dart';
import 'package:tokona/features/customer/domain/models/customer_model.dart';
import 'package:tokona/features/customer/domain/models/customer_receivable_payment_model.dart';
import 'package:tokona/features/pos/domain/models/sale_model.dart';
import 'package:tokona/features/purchase/data/daos/payment_account_dao.dart';

class CustomerRepository {
  final AppDatabase _appDatabase;
  late final CustomerDao _customerDao;
  late final CustomerReceivablePaymentDao _paymentDao;
  late final PaymentAccountDao _paymentAccountDao;
  Database? _db;

  CustomerRepository(this._appDatabase) {
    _customerDao = CustomerDao(() => _db!);
    _paymentDao = const CustomerReceivablePaymentDao();
    _paymentAccountDao = const PaymentAccountDao();
  }

  Future<void> initialize() async {
    _db = await _appDatabase.database;
  }

  Future<CustomerModel> createCustomer(String storeId, CreateCustomerDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) throw ArgumentError(validationError);

    final now = DateTime.now();
    final customerId = IdGenerator.generateId(prefix: 'CST');

    final customer = CustomerModel(
      id: customerId,
      storeId: storeId,
      name: dto.name.trim(),
      phone: dto.phone?.trim().isEmpty ?? true ? null : dto.phone?.trim(),
      address: dto.address?.trim().isEmpty ?? true ? null : dto.address?.trim(),
      customerType: dto.customerType.toLowerCase(),
      notes: dto.notes?.trim().isEmpty ?? true ? null : dto.notes?.trim(),
      receivableBalance: dto.initialReceivableBalance,
      createdAt: now,
      updatedAt: now,
    );

    await _customerDao.insertCustomer(customer);
    return customer;
  }

  Future<CustomerModel> updateCustomer(String id, UpdateCustomerDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) throw ArgumentError(validationError);

    final existing = await _customerDao.getCustomerById(id);
    if (existing == null) throw ArgumentError('Pelanggan tidak ditemukan');

    final updated = existing.copyWith(
      name: dto.name?.trim(),
      phone: dto.phone?.trim().isEmpty ?? false ? null : dto.phone?.trim(),
      address: dto.address?.trim().isEmpty ?? false ? null : dto.address?.trim(),
      customerType: dto.customerType?.toLowerCase(),
      notes: dto.notes?.trim().isEmpty ?? false ? null : dto.notes?.trim(),
      receivableBalance: dto.receivableBalance,
      updatedAt: DateTime.now(),
    );

    await _customerDao.updateCustomer(updated);
    return updated;
  }

  Future<void> deleteCustomer(String id) async {
    await initialize();
    await _customerDao.deleteCustomer(id);
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    await initialize();
    return await _customerDao.getCustomerById(id);
  }

  Future<List<CustomerModel>> getCustomers(
    String storeId, {
    String? type,
    String? searchQuery,
  }) async {
    await initialize();
    return await _customerDao.getCustomersByStore(
      storeId,
      type: type,
      searchQuery: searchQuery,
    );
  }

  Future<void> adjustReceivable(String customerId, double deltaAmount) async {
    await initialize();
    await _customerDao.adjustReceivable(customerId, deltaAmount);
  }

  Future<void> recordReceivablePayment(CustomerReceivablePaymentModel payment) async {
    await initialize();
    await _db!.transaction((txn) async {
      await _paymentDao.insert(txn, payment);
      await _customerDao.adjustReceivable(payment.customerId, -payment.amount, txn: txn);

      if (payment.accountId != null && payment.accountId!.isNotEmpty) {
        await _paymentAccountDao.adjustBalance(
          txn,
          storeId: payment.storeId,
          accountNameOrId: payment.accountId!,
          deltaAmount: payment.amount,
        );
      }
    });
  }

  Future<List<CustomerReceivablePaymentModel>> getReceivablePayments(String customerId) async {
    await initialize();
    return await _paymentDao.getByCustomerId(_db!, customerId);
  }

  Future<List<SaleModel>> getCustomerReceivableSales(String customerId) async {
    await initialize();
    final rows = await _db!.query(
      DatabaseTables.sales,
      where: '${DatabaseTables.columnSaleCustomerId} = ? AND UPPER(${DatabaseTables.columnSalePaymentMethod}) = ?',
      whereArgs: [customerId, 'KASBON'],
      orderBy: '${DatabaseTables.columnCreatedAt} DESC',
    );
    return rows.map(SaleModel.fromMap).toList();
  }
}
