import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PaylaterSettlementState {
  final Set<String> settledMonths; // format: 'YYYY-MM'

  const PaylaterSettlementState({this.settledMonths = const {}});

  bool isSettled(int year, int month) => settledMonths.contains(_key(year, month));

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
        final list = (jsonDecode(content) as List).map((e) => e.toString()).toSet();
        state = PaylaterSettlementState(settledMonths: list);
      }
    } catch (_) {}
  }

  Future<void> markSettled(int year, int month) async {
    final key = PaylaterSettlementState._key(year, month);
    final updated = {...state.settledMonths, key};
    state = PaylaterSettlementState(settledMonths: updated);
    _save();
  }

  Future<void> unmarkSettled(int year, int month) async {
    final key = PaylaterSettlementState._key(year, month);
    final updated = state.settledMonths.where((k) => k != key).toSet();
    state = PaylaterSettlementState(settledMonths: updated);
    _save();
  }

  Future<void> _save() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state.settledMonths.toList()));
    } catch (_) {}
  }
}

final paylaterSettlementProvider = StateNotifierProvider<PaylaterSettlementNotifier, PaylaterSettlementState>((ref) {
  return PaylaterSettlementNotifier();
});
