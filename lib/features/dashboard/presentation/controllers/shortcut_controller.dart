import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tokona/features/dashboard/domain/models/shortcut_menu_item.dart';

final shortcutControllerProvider =
    StateNotifierProvider<ShortcutController, List<String>>((ref) {
  return ShortcutController()..init();
});

class ShortcutController extends StateNotifier<List<String>> {
  ShortcutController() : super(AppShortcutRegistry.defaultPinnedIds);

  bool _initialized = false;

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tokona_pinned_shortcuts.json');
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content) as List<dynamic>;
        final loaded = decoded.map((e) => e.toString()).toList();
        final validList = loaded
            .where((id) => AppShortcutRegistry.findById(id) != null)
            .toList();
        if (validList.isNotEmpty) {
          state = validList;
          return;
        }
      }
    } catch (_) {}
    state = List.from(AppShortcutRegistry.defaultPinnedIds);
  }

  Future<void> _save() async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(state));
    } catch (_) {}
  }

  Future<void> togglePin(String id) async {
    if (state.contains(id)) {
      if (state.length <= 1) return; // Sisakan minimal 1
      state = state.where((item) => item != id).toList();
    } else {
      if (state.length >= 15) return; // Maksimal 15 pintasan
      state = [...state, id];
    }
    await _save();
  }

  Future<void> setPinned(List<String> ids) async {
    final valid = ids.where((id) => AppShortcutRegistry.findById(id) != null).toList();
    if (valid.isNotEmpty) {
      state = valid;
      await _save();
    }
  }

  Future<void> resetToDefault() async {
    state = List.from(AppShortcutRegistry.defaultPinnedIds);
    await _save();
  }
}

