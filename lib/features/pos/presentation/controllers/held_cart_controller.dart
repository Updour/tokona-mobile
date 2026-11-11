import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tokona/features/pos/domain/models/cart_state.dart';
import 'package:tokona/features/pos/domain/models/held_cart_model.dart';

final heldCartProvider = StateNotifierProvider<HeldCartController, List<HeldCartModel>>((ref) {
  return HeldCartController()..loadPersistedReminders();
});

class HeldCartController extends StateNotifier<List<HeldCartModel>> {
  HeldCartController() : super(const []);

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tokona_scheduled_reminders.json');
  }

  Future<void> loadPersistedReminders() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> decoded = jsonDecode(content) as List<dynamic>;
        final List<HeldCartModel> loaded = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            loaded.add(HeldCartModel(
              id: item['id'] as String,
              customerName: item['customerName'] as String?,
              customerPhone: item['customerPhone'] as String?,
              note: item['note'] as String?,
              deliveryMethod: item['deliveryMethod'] as String? ?? 'pickup',
              plannedDate: item['plannedDate'] != null ? DateTime.tryParse(item['plannedDate'] as String) : null,
              heldAt: DateTime.tryParse(item['heldAt'] as String? ?? '') ?? DateTime.now(),
              items: const [],
              manualAmount: (item['manualAmount'] as num?)?.toDouble(),
              discountAmount: (item['discountAmount'] as num?)?.toDouble() ?? 0.0,
              waStatus: item['waStatus'] as String? ?? 'MENUNGGU',
              waSentAt: item['waSentAt'] != null ? DateTime.tryParse(item['waSentAt'] as String) : null,
              waLogMessage: item['waLogMessage'] as String?,
            ));
          }
        }
        if (loaded.isNotEmpty) {
          state = [...state, ...loaded.where((l) => !state.any((s) => s.id == l.id))];
        }
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final file = await _getFile();
      final toSave = state.map((h) => {
        'id': h.id,
        'customerName': h.customerName,
        'customerPhone': h.customerPhone,
        'note': h.note,
        'deliveryMethod': h.deliveryMethod,
        'plannedDate': h.plannedDate?.toIso8601String(),
        'heldAt': h.heldAt.toIso8601String(),
        'manualAmount': h.manualAmount,
        'discountAmount': h.discountAmount,
        'waStatus': h.waStatus,
        'waSentAt': h.waSentAt?.toIso8601String(),
        'waLogMessage': h.waLogMessage,
      }).toList();
      await file.writeAsString(jsonEncode(toSave));
    } catch (_) {}
  }

  void holdCart({
    required CartState cart,
    String? customerName,
    String? customerPhone,
    String? note,
    String deliveryMethod = 'pickup',
    DateTime? plannedDate,
  }) {
    if (cart.isEmpty) return;

    final newHeld = HeldCartModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: customerName?.trim().isNotEmpty == true ? customerName!.trim() : cart.customerName,
      customerPhone: customerPhone?.trim().isNotEmpty == true ? customerPhone!.trim() : null,
      note: note?.trim().isNotEmpty == true ? note!.trim() : null,
      deliveryMethod: deliveryMethod,
      plannedDate: plannedDate,
      heldAt: DateTime.now(),
      items: List.from(cart.items),
      discountAmount: cart.discountAmount,
    );

    state = [newHeld, ...state];
    _persist();
  }

  void addManualReminder({
    required String customerName,
    required String customerPhone,
    String? note,
    double totalAmount = 0.0,
    String deliveryMethod = 'pickup',
    DateTime? plannedDate,
  }) {
    final newHeld = HeldCartModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: customerName.trim(),
      customerPhone: customerPhone.trim(),
      note: note?.trim().isNotEmpty == true ? note!.trim() : null,
      deliveryMethod: deliveryMethod,
      plannedDate: plannedDate,
      heldAt: DateTime.now(),
      items: const [],
      discountAmount: 0.0,
      manualAmount: totalAmount,
      waStatus: 'MENUNGGU',
    );

    state = [newHeld, ...state];
    _persist();
  }

  void updatePlannedDate(String id, DateTime? newDate) {
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            plannedDate: newDate,
            waStatus: 'MENUNGGU',
            waLogMessage: 'Jadwal diubah, siap kirim ulang',
          )
        else
          h,
    ];
    _persist();
  }

  void markWaSent(String id, {required String phone, String? logMessage}) {
    final now = DateTime.now();
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            waStatus: 'TERKIRIM',
            waSentAt: now,
            waLogMessage: logMessage ?? 'WhatsApp dialihkan ke $phone',
          )
        else
          h,
    ];
    _persist();
  }

  void markWaFailed(String id, {required String reason}) {
    state = [
      for (final h in state)
        if (h.id == id)
          h.copyWith(
            waStatus: 'GAGAL',
            waLogMessage: reason,
          )
        else
          h,
    ];
    _persist();
  }

  HeldCartModel? restoreHeldCart(String id) {
    final index = state.indexWhere((h) => h.id == id);
    if (index < 0) return null;

    final held = state[index];
    final updated = List<HeldCartModel>.from(state)..removeAt(index);
    state = updated;
    _persist();
    return held;
  }

  void removeHeldCart(String id) {
    state = state.where((h) => h.id != id).toList();
    _persist();
  }

  void clearAll() {
    state = const [];
    _persist();
  }
}
