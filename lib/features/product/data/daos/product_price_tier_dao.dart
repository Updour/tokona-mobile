import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/features/product/domain/models/product_price_tier_model.dart';

class ProductPriceTierDao {
  final Database Function() _getDatabase;

  ProductPriceTierDao(this._getDatabase);

  Future<void> insertTier(ProductPriceTierModel tier, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.insert(
      DatabaseTables.productPriceTiers,
      tier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductPriceTierModel>> getTiersByProductId(String productId) async {
    final db = _getDatabase();
    final results = await db.query(
      DatabaseTables.productPriceTiers,
      where: '${DatabaseTables.columnTierProductId} = ?',
      whereArgs: [productId],
      orderBy: '${DatabaseTables.columnTierMinQuantity} ASC',
    );
    return results.map((e) => ProductPriceTierModel.fromMap(e)).toList();
  }

  /// Batch query untuk mengambil tingkatan harga grosir banyak produk sekaligus
  Future<Map<String, List<ProductPriceTierModel>>> getTiersByProductIds(List<String> productIds) async {
    if (productIds.isEmpty) return {};
    final db = _getDatabase();
    final map = <String, List<ProductPriceTierModel>>{};
    const chunkSize = 500;
    for (var i = 0; i < productIds.length; i += chunkSize) {
      final chunk = productIds.sublist(i, (i + chunkSize > productIds.length) ? productIds.length : i + chunkSize);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final results = await db.query(
        DatabaseTables.productPriceTiers,
        where: '${DatabaseTables.columnTierProductId} IN ($placeholders)',
        whereArgs: chunk,
        orderBy: '${DatabaseTables.columnTierMinQuantity} ASC',
      );
      for (final row in results) {
        final tier = ProductPriceTierModel.fromMap(row);
        map.putIfAbsent(tier.productId, () => []).add(tier);
      }
    }
    return map;
  }

  Future<void> deleteTiersByProductId(String productId, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.productPriceTiers,
      where: '${DatabaseTables.columnTierProductId} = ?',
      whereArgs: [productId],
    );
  }
}
