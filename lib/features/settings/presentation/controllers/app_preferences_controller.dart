import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tokona/features/settings/domain/models/app_preferences.dart';

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesController, AppPreferences>((ref) {
  return AppPreferencesController();
});

class AppPreferencesController extends StateNotifier<AppPreferences> {
  AppPreferencesController() : super(const AppPreferences()) {
    _load();
  }

  Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, 'tokona_app_preferences.json'));
  }

  Future<void> _load() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final map = jsonDecode(content) as Map<String, dynamic>;
        state = AppPreferences.fromMap(map);
      }
    } catch (_) {}
  }

  Future<void> save(AppPreferences updated) async {
    state = updated;
    await _persist();
  }

  Future<void> update(AppPreferences Function(AppPreferences current) updater) async {
    state = updater(state);
    await _persist();
  }

  Future<void> resetToDefaults() async {
    state = const AppPreferences();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state.toMap()));
    } catch (_) {}
  }
}
