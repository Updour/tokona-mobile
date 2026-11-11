import 'package:tokona/core/database/database_tables.dart';

class StoreCapitalModel {
  final String id;
  final String storeId;
  final double amount;
  final String type;
  final DateTime capitalDate;
  final String? accountId;
  final String? accountName;
  final String? source;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoreCapitalModel({
    required this.id,
    required this.storeId,
    required this.amount,
    this.type = 'TAMBAH_MODAL',
    required this.capitalDate,
    this.accountId,
    this.accountName,
    this.source,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isWithdrawal => type == 'TARIK_MODAL';

  String get typeLabel {
    switch (type) {
      case 'MODAL_AWAL':
        return 'Modal Awal';
      case 'TARIK_MODAL':
        return 'Tarik Modal (Prive)';
      case 'TAMBAH_MODAL':
      default:
        return 'Tambahan Modal';
    }
  }

  factory StoreCapitalModel.fromMap(Map<String, dynamic> map) {
    return StoreCapitalModel(
      id: map[DatabaseTables.columnId] as String,
      storeId: map[DatabaseTables.columnCapitalStoreId] as String,
      amount: (map[DatabaseTables.columnCapitalAmount] as num).toDouble(),
      type: map[DatabaseTables.columnCapitalType] as String? ?? 'TAMBAH_MODAL',
      capitalDate: DateTime.parse(map[DatabaseTables.columnCapitalDate] as String),
      accountId: map[DatabaseTables.columnCapitalAccountId] as String?,
      accountName: map[DatabaseTables.columnCapitalAccountName] as String?,
      source: map[DatabaseTables.columnCapitalSource] as String?,
      notes: map[DatabaseTables.columnCapitalNotes] as String?,
      createdAt: DateTime.parse(map[DatabaseTables.columnCreatedAt] as String),
      updatedAt: DateTime.parse(map[DatabaseTables.columnUpdatedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.columnId: id,
      DatabaseTables.columnCapitalStoreId: storeId,
      DatabaseTables.columnCapitalAmount: amount,
      DatabaseTables.columnCapitalType: type,
      DatabaseTables.columnCapitalDate: capitalDate.toIso8601String(),
      DatabaseTables.columnCapitalAccountId: accountId,
      DatabaseTables.columnCapitalAccountName: accountName,
      DatabaseTables.columnCapitalSource: source,
      DatabaseTables.columnCapitalNotes: notes,
      DatabaseTables.columnCreatedAt: createdAt.toIso8601String(),
      DatabaseTables.columnUpdatedAt: updatedAt.toIso8601String(),
    };
  }
}
