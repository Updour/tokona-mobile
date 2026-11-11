import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/supplier/data/daos/supplier_dao.dart';
import 'package:tokona/features/supplier/domain/dtos/create_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/dtos/update_supplier_dto.dart';
import 'package:tokona/features/supplier/domain/models/supplier_model.dart';

class SupplierRepository {
  final AppDatabase _appDatabase;
  late final SupplierDao _supplierDao;
  Database? _db;

  SupplierRepository(this._appDatabase) {
    _supplierDao = SupplierDao(() => _db!);
  }

  Future<void> initialize() async {
    _db = await _appDatabase.database;
  }

  Future<SupplierModel> createSupplier(String storeId, CreateSupplierDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final now = DateTime.now();
    final supplierId = IdGenerator.generateId(prefix: 'SPL');

    final supplier = SupplierModel(
      id: supplierId,
      storeId: storeId,
      name: dto.name.trim(),
      type: dto.type.toLowerCase(),
      platform: dto.platform?.trim().isEmpty ?? true ? null : dto.platform?.trim(),
      contactName: dto.contactName?.trim().isEmpty ?? true ? null : dto.contactName?.trim(),
      phone: dto.phone?.trim().isEmpty ?? true ? null : dto.phone?.trim(),
      address: dto.address?.trim().isEmpty ?? true ? null : dto.address?.trim(),
      notes: dto.notes?.trim().isEmpty ?? true ? null : dto.notes?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _supplierDao.insertSupplier(supplier);
    return supplier;
  }

  Future<SupplierModel> updateSupplier(String id, UpdateSupplierDto dto) async {
    await initialize();

    final validationError = dto.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final existing = await _supplierDao.getSupplierById(id);
    if (existing == null) {
      throw StateError('Supplier tidak ditemukan');
    }

    final now = DateTime.now();
    final updated = existing.copyWith(
      name: dto.name.trim(),
      type: dto.type.toLowerCase(),
      platform: dto.platform?.trim().isEmpty ?? true ? null : dto.platform?.trim(),
      contactName: dto.contactName?.trim().isEmpty ?? true ? null : dto.contactName?.trim(),
      phone: dto.phone?.trim().isEmpty ?? true ? null : dto.phone?.trim(),
      address: dto.address?.trim().isEmpty ?? true ? null : dto.address?.trim(),
      notes: dto.notes?.trim().isEmpty ?? true ? null : dto.notes?.trim(),
      updatedAt: now,
    );

    await _supplierDao.updateSupplier(updated);
    return updated;
  }

  Future<void> deleteSupplier(String id) async {
    await initialize();
    await _supplierDao.deleteSupplier(id);
  }

  Future<List<SupplierModel>> getSuppliers(
    String storeId, {
    String? type,
    String? searchQuery,
  }) async {
    await initialize();
    return await _supplierDao.getSuppliersByStore(
      storeId,
      type: type,
      searchQuery: searchQuery,
    );
  }
}
