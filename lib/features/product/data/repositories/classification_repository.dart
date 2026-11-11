import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/product/data/daos/category_dao.dart';
import 'package:tokona/features/product/data/daos/product_type_dao.dart';

class ClassificationRepository {
  final AppDatabase _appDatabase;
  late final CategoryDao _categoryDao;
  late final ProductTypeDao _productTypeDao;
  Database? _db;

  static const List<String> defaultCategories = [
    'Makanan',
    'Minuman',
    'Sembako',
    'Snack',
    'Bumbu Dapur',
    'Rokok',
    'Kebersihan',
  ];

  static const List<String> defaultProductTypes = [
    'Fisik',
    'Fresh / Frozen',
    'Konsinyasi',
    'Jasa',
  ];

  ClassificationRepository(this._appDatabase) {
    _categoryDao = CategoryDao(() => _db!);
    _productTypeDao = ProductTypeDao(() => _db!);
  }

  Future<void> initialize() async {
    _db = await _appDatabase.database;
  }

  Future<List<String>> getCategories(String storeId) async {
    await initialize();
    final customCats = await _categoryDao.getCategoriesByStore(storeId);
    final productCatsResult = await _db!.rawQuery(
      'SELECT DISTINCT ${DatabaseTables.columnProductCategory} as cat FROM ${DatabaseTables.products} WHERE ${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductCategory} IS NOT NULL',
      [storeId],
    );
    final productCats = productCatsResult.map((r) => r['cat'] as String).where((c) => c.trim().isNotEmpty).toList();

    final Set<String> merged = {...defaultCategories, ...customCats, ...productCats};
    return merged.toList();
  }

  Future<List<String>> getProductTypes(String storeId) async {
    await initialize();
    final customTypes = await _productTypeDao.getTypesByStore(storeId);
    final productTypesResult = await _db!.rawQuery(
      'SELECT DISTINCT ${DatabaseTables.columnProductType} as ptype FROM ${DatabaseTables.products} WHERE ${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductType} IS NOT NULL',
      [storeId],
    );
    final productTypes = productTypesResult.map((r) => r['ptype'] as String).where((t) => t.trim().isNotEmpty).toList();

    final Set<String> merged = {...defaultProductTypes, ...customTypes, ...productTypes};
    return merged.toList();
  }

  Future<void> ensureCategory(String storeId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'Lainnya') return;
    await initialize();
    final id = IdGenerator.generateId(prefix: 'CAT');
    await _categoryDao.insertCategory(id: id, storeId: storeId, name: trimmed);
  }

  Future<void> ensureProductType(String storeId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'Lainnya') return;
    await initialize();
    final id = IdGenerator.generateId(prefix: 'TYP');
    await _productTypeDao.insertType(id: id, storeId: storeId, name: trimmed);
  }

  Future<void> updateCategory(String storeId, String oldName, String newName) async {
    await initialize();
    final trimmedNew = newName.trim();
    if (trimmedNew.isEmpty) return;
    await _db!.transaction((txn) async {
      await _categoryDao.updateCategory(storeId: storeId, oldName: oldName, newName: trimmedNew, txn: txn);
      await txn.update(
        DatabaseTables.products,
        {DatabaseTables.columnProductCategory: trimmedNew},
        where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductCategory} = ?',
        whereArgs: [storeId, oldName],
      );
    });
  }

  Future<void> deleteCategory(String storeId, String name) async {
    await initialize();
    await _db!.transaction((txn) async {
      await _categoryDao.deleteCategory(storeId: storeId, name: name, txn: txn);
      await txn.update(
        DatabaseTables.products,
        {DatabaseTables.columnProductCategory: null},
        where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductCategory} = ?',
        whereArgs: [storeId, name],
      );
    });
  }

  Future<void> updateProductType(String storeId, String oldName, String newName) async {
    await initialize();
    final trimmedNew = newName.trim();
    if (trimmedNew.isEmpty) return;
    await _db!.transaction((txn) async {
      await _productTypeDao.updateType(storeId: storeId, oldName: oldName, newName: trimmedNew, txn: txn);
      await txn.update(
        DatabaseTables.products,
        {DatabaseTables.columnProductType: trimmedNew},
        where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductType} = ?',
        whereArgs: [storeId, oldName],
      );
    });
  }

  Future<void> deleteProductType(String storeId, String name) async {
    await initialize();
    await _db!.transaction((txn) async {
      await _productTypeDao.deleteType(storeId: storeId, name: name, txn: txn);
      await txn.update(
        DatabaseTables.products,
        {DatabaseTables.columnProductType: 'Fisik'},
        where: '${DatabaseTables.columnProductStoreId} = ? AND ${DatabaseTables.columnProductType} = ?',
        whereArgs: [storeId, name],
      );
    });
  }
}
