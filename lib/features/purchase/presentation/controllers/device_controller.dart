import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tokona/features/purchase/data/daos/device_dao.dart';

final deviceDaoProvider = Provider<DeviceDao>((ref) => const DeviceDao());

final deviceListProvider = StateNotifierProvider<DeviceController, List<String>>((ref) {
  final appDb = ref.watch(appDatabaseProvider);
  final dao = ref.watch(deviceDaoProvider);
  return DeviceController(appDb, dao);
});

class DeviceController extends StateNotifier<List<String>> {
  final dynamic _appDb;
  final DeviceDao _dao;

  DeviceController(this._appDb, this._dao) : super(const []);

  Future<void> loadDevices(String storeId) async {
    final db = await _appDb.database;
    final list = await _dao.getDevices(db, storeId);
    state = list;
  }

  Future<String?> addDevice(String storeId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final db = await _appDb.database;
    await _dao.addDevice(db, storeId, trimmed);
    await loadDevices(storeId);
    return trimmed;
  }

  Future<void> updateDevice(String storeId, String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final db = await _appDb.database;
    await _dao.updateDevice(db, storeId, oldName, trimmed);
    await loadDevices(storeId);
  }

  Future<void> deleteDevice(String storeId, String name) async {
    final db = await _appDb.database;
    await _dao.deleteDevice(db, storeId, name);
    await loadDevices(storeId);
  }
}
