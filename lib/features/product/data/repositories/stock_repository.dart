import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/product/data/daos/stock_mutation_dao.dart';
import 'package:tokona/features/product/domain/dtos/create_stock_adjustment_dto.dart';
import 'package:tokona/features/product/domain/models/product_model.dart';
import 'package:tokona/features/product/domain/models/stock_mutation_model.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  return StockRepository(
    appDatabase: appDb,
    mutationDao: const StockMutationDao(),
  );
});

class StockRepository {
  final AppDatabase appDatabase;
  final StockMutationDao mutationDao;

  const StockRepository({
    required this.appDatabase,
    required this.mutationDao,
  });

  Future<StockMutationModel> adjustStock(CreateStockAdjustmentDto dto) async {
    final validationError = dto.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    final db = await appDatabase.database;
    final now = DateTime.now();

    return await db.transaction<StockMutationModel>((txn) async {
      final rows = await txn.query(
        DatabaseTables.products,
        where: '${DatabaseTables.columnId} = ?',
        whereArgs: [dto.productId],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw StateError('Produk tidak ditemukan');
      }

      final product = ProductModel.fromMap(rows.first);
      final prevStock = product.stockBase;
      double newStock;

      if (dto.isIn) {
        newStock = prevStock + dto.adjustmentQty;
      } else {
        newStock = prevStock - dto.adjustmentQty;
        if (newStock < 0) {
          throw ArgumentError('Stok tidak boleh kurang dari 0. Stok saat ini: $prevStock');
        }
      }

      await txn.update(
        DatabaseTables.products,
        {
          DatabaseTables.columnProductStockBase: newStock,
          DatabaseTables.columnUpdatedAt: now.toIso8601String(),
        },
        where: '${DatabaseTables.columnId} = ?',
        whereArgs: [dto.productId],
      );

      final mutationId = IdGenerator.generateId(prefix: 'MUT');
      final mutation = StockMutationModel(
        id: mutationId,
        storeId: dto.storeId,
        productId: dto.productId,
        productName: product.name,
        type: dto.type,
        quantity: dto.adjustmentQty,
        previousStock: prevStock,
        currentStock: newStock,
        reason: dto.reason,
        notes: dto.notes?.trim().isEmpty == true ? null : dto.notes?.trim(),
        createdAt: now,
      );

      await mutationDao.insert(txn, mutation);
      return mutation;
    });
  }

  Future<List<StockMutationModel>> getMutationsByProduct(
    String productId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await appDatabase.database;
    return await mutationDao.getByProductId(db, productId, limit: limit, offset: offset);
  }

  Future<List<StockMutationModel>> getRecentMutations(
    String storeId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await appDatabase.database;
    return await mutationDao.getByStoreId(db, storeId, limit: limit, offset: offset);
  }

  Future<void> logMutationInTransaction(
    DatabaseExecutor txn, {
    required String storeId,
    required String productId,
    required String type,
    required double quantity,
    required double previousStock,
    required double currentStock,
    required String reason,
    String? referenceId,
    String? notes,
    required DateTime now,
  }) async {
    final mutationId = IdGenerator.generateId(prefix: 'MUT');
    final mutation = StockMutationModel(
      id: mutationId,
      storeId: storeId,
      productId: productId,
      type: type,
      quantity: quantity,
      previousStock: previousStock,
      currentStock: currentStock,
      reason: reason,
      referenceId: referenceId,
      notes: notes,
      createdAt: now,
    );
    await mutationDao.insert(txn, mutation);
  }
}

