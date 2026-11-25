import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/product/domain/models/product_unit_model.dart';

class ProductUnitDao {
  final Database Function() _getDatabase;

  ProductUnitDao(this._getDatabase);

  Future<void> insertUnit(ProductUnitModel unit, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.productUnits,
      unit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductUnitModel>> getUnitsByProductId(String productId) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.productUnits,
      where: '${DatabaseTables.columnUnitProductId} = ?',
      whereArgs: [productId],
      orderBy: '${DatabaseTables.columnUnitConversionFactor} ASC',
    );
    return results.map((e) => ProductUnitModel.fromMap(e)).toList();
  }

  /// Batch query untuk mengambil unit banyak produk sekaligus (mencegah N+1 query)
  Future<Map<String, List<ProductUnitModel>>> getUnitsByProductIds(List<String> productIds) async {
    if (productIds.isEmpty) return {};
    final db = _getDatabase();
    final map = <String, List<ProductUnitModel>>{};
    const chunkSize = 500;
    for (var i = 0; i < productIds.length; i += chunkSize) {
      final chunk = productIds.sublist(i, (i + chunkSize > productIds.length) ? productIds.length : i + chunkSize);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final results = await db.query(
        DatabaseTables.productUnits,
        where: '${DatabaseTables.columnUnitProductId} IN ($placeholders)',
        whereArgs: chunk,
        orderBy: '${DatabaseTables.columnUnitConversionFactor} ASC',
      );
      for (final row in results) {
        final unit = ProductUnitModel.fromMap(row);
        map.putIfAbsent(unit.productId, () => []).add(unit);
      }
    }
    return map;
  }

  Future<void> deleteUnitsByProductId(String productId, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.productUnits,
      where: '${DatabaseTables.columnUnitProductId} = ?',
      whereArgs: [productId],
    );
  }

  Future<void> deleteUnit(String unitId, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.productUnits,
      where: '${DatabaseTables.columnId} = ?',
      whereArgs: [unitId],
    );
  }
}
