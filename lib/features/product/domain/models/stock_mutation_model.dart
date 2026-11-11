import 'package:flutter/material.dart';
import 'package:tokona/core/database/database_tables.dart';

class StockMutationModel {
  final String id;
  final String storeId;
  final String productId;
  final String? productName;
  final String type;
  final double quantity;
  final double previousStock;
  final double currentStock;
  final String reason;
  final String? referenceId;
  final String? notes;
  final DateTime createdAt;

  const StockMutationModel({
    required this.id,
    required this.storeId,
    required this.productId,
    this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.currentStock,
    required this.reason,
    this.referenceId,
    this.notes,
    required this.createdAt,
  });

  bool get isIn => type.toLowerCase() == 'in';
  bool get isOut => type.toLowerCase() == 'out';

  String get readableReason {
    switch (reason.toLowerCase()) {
      case 'sale':
        return 'Penjualan Kasir';
      case 'purchase':
        return 'Pembelian / Belanja Stok';
      case 'damaged':
        return 'Barang Rusak / Pecah';
      case 'expired':
        return 'Kadaluarsa (Expired)';
      case 'lost':
        return 'Hilang / Selisih Fisik';
      case 'internal_use':
        return 'Pemakaian Toko';
      case 'opname_in':
        return 'Koreksi Fisik Masuk (+)';
      case 'opname_out':
        return 'Koreksi Selisih Opname (-)';
      default:
        return 'Penyesuaian Manual';
    }
  }

  Color get reasonColor {
    switch (reason.toLowerCase()) {
      case 'sale':
        return const Color(0xFF0D9488);
      case 'purchase':
        return const Color(0xFF2563EB);
      case 'damaged':
      case 'expired':
        return const Color(0xFFDC2626);
      case 'lost':
        return const Color(0xFFEA580C);
      case 'internal_use':
        return const Color(0xFF7C3AED);
      case 'opname_in':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF4B5563);
    }
  }

  factory StockMutationModel.fromMap(Map<String, dynamic> map) {
    return StockMutationModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnMutationStoreId] as String,
      productId: map[DatabaseTables.columnMutationProductId] as String,
      productName: map['product_name'] as String?,
      type: map[DatabaseTables.columnMutationType] as String,
      quantity: (map[DatabaseTables.columnMutationQuantity] as num).toDouble(),
      previousStock: (map[DatabaseTables.columnMutationPreviousStock] as num).toDouble(),
      currentStock: (map[DatabaseTables.columnMutationCurrentStock] as num).toDouble(),
      reason: map[DatabaseTables.columnMutationReason] as String,
      referenceId: map[DatabaseTables.columnMutationReferenceId] as String?,
      notes: map[DatabaseTables.columnMutationNotes] as String?,
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnMutationStoreId: storeId,
      DatabaseTables.columnMutationProductId: productId,
      DatabaseTables.columnMutationType: type,
      DatabaseTables.columnMutationQuantity: quantity,
      DatabaseTables.columnMutationPreviousStock: previousStock,
      DatabaseTables.columnMutationCurrentStock: currentStock,
      DatabaseTables.columnMutationReason: reason,
      DatabaseTables.columnMutationReferenceId: referenceId,
      DatabaseTables.columnMutationNotes: notes,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
    };
  }
}

