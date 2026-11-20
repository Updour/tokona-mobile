import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SettlementRecord {
  final String key;
  final String? accountId;
  final String? accountName;
  final double amount;
  final DateTime settledAt;

  const SettlementRecord({
    required this.key,
    this.accountId,
    this.accountName,
    required this.amount,
    required this.settledAt,
  });

  Map<String, dynamic> toMap() => {
        'key': key,
        'accountId': accountId,
        'accountName': accountName,
        'amount': amount,
        'settledAt': settledAt.toIso8601String(),
      };

  factory SettlementRecord.fromMap(Map<String, dynamic> map) => SettlementRecord(
        key: map['key'] as String? ?? '',
        accountId: map['accountId'] as String?,
        accountName: map['accountName'] as String?,
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        settledAt: DateTime.tryParse(map['settledAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class PaylaterSettlementState {
  final Map<String, SettlementRecord> records; // key format: 'YYYY-MM'

  const PaylaterSettlementState({this.records = const {}});

  bool isSettled(int year, int month) => records.containsKey(_key(year, month));

  SettlementRecord? getRecord(int year, int month) => records[_key(year, month)];

  static String _key(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';
}

class PaylaterSettlementNotifier extends StateNotifier<PaylaterSettlementState> {
  PaylaterSettlementNotifier() : super(const PaylaterSettlementState()) {
    _load();
  }

  Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_paylater_settlement.json'));
  }

  Future<void> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final decoded = jsonDecode(content);
        final Map<String, SettlementRecord> map = {};
        if (decoded is List) {
          for (final item in decoded) {
            if (item is String) {
              map[item] = SettlementRecord(key: item, amount: 0.0, settledAt: DateTime.now());
            } else if (item is Map<String, dynamic>) {
              final rec = SettlementRecord.fromMap(item);
              if (rec.key.isNotEmpty) map[rec.key] = rec;
            }
          }
        }
        state = PaylaterSettlementState(records: map);
      }
    } catch (_) {}
  }

  Future<void> markSettled(
    int year,
    int month, {
    String? accountId,
    String? accountName,
    double amount = 0.0,
  }) async {
    final key = PaylaterSettlementState._key(year, month);
    final record = SettlementRecord(
      key: key,
      accountId: accountId,
      accountName: accountName,
      amount: amount,
      settledAt: DateTime.now(),
    );
    final updated = {...state.records, key: record};
    state = PaylaterSettlementState(records: updated);
    _save();
  }

  Future<SettlementRecord?> unmarkSettled(int year, int month) async {
    final key = PaylaterSettlementState._key(year, month);
    final existing = state.records[key];
    final updated = Map<String, SettlementRecord>.from(state.records)..remove(key);
    state = PaylaterSettlementState(records: updated);
    _save();
    return existing;
  }

  Future<void> _save() async {
    try {
      final file = await _getFile();
      final list = state.records.values.map((r) => r.toMap()).toList();
      await file.writeAsString(jsonEncode(list));
    } catch (_) {}
  }
}

final paylaterSettlementProvider = StateNotifierProvider<PaylaterSettlementNotifier, PaylaterSettlementState>((ref) {
  return PaylaterSettlementNotifier();
});
