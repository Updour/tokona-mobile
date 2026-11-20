import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tokona/features/pos/domain/models/wa_message_log.dart';

final waHistoryProvider = StateNotifierProvider<WaHistoryController, List<WaMessageLog>>((ref) {
  return WaHistoryController();
});

class WaHistoryController extends StateNotifier<List<WaMessageLog>> {
  WaHistoryController() : super(const []) {
    _load();
  }

  static const int _maxLogs = 150;

  Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_wa_history.json'));
  }

  Future<void> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final raw = await file.readAsString();
        final list = (jsonDecode(raw) as List)
            .map((e) => WaMessageLog.fromMap(e as Map<String, dynamic>))
            .toList();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> recordLog(WaMessageLog log) async {
    final next = [log, ...state.where((e) => e.id != log.id)];
    state = next.length > _maxLogs ? next.sublist(0, _maxLogs) : next;
    await _persist();
  }

  Future<void> deleteLog(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state.map((e) => e.toMap()).toList()));
    } catch (_) {}
  }
}
