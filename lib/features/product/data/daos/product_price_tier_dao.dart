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

  Future<void> deleteTiersByProductId(String productId, {Transaction? txn}) async {
    final executor = txn ?? _getDatabase();
    await executor.delete(
      DatabaseTables.productPriceTiers,
      where: '${DatabaseTables.columnTierProductId} = ?',
      whereArgs: [productId],
    );
  }
}
