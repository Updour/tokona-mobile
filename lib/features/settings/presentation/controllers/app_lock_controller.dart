import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/settings/data/services/app_lock_service.dart';
import 'package:tokona/features/settings/domain/models/app_lock_config.dart';

class AppLockState {
  final AppLockConfig config;
  final bool isUnlocked;

  const AppLockState({
    this.config = const AppLockConfig(),
    this.isUnlocked = false,
  });

  bool get isLocked => config.isEnabled && config.hasPin && !isUnlocked;

  AppLockState copyWith({
    AppLockConfig? config,
    bool? isUnlocked,
  }) {
    return AppLockState(
      config: config ?? this.config,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

final appLockProvider = StateNotifierProvider<AppLockController, AppLockState>((ref) {
  return AppLockController();
});

class AppLockController extends StateNotifier<AppLockState> {
  AppLockController() : super(const AppLockState()) {
    init();
  }

  Future<void> init() async {
    final conf = await AppLockService.loadConfig();
    state = state.copyWith(
      config: conf,
      isUnlocked: !conf.isEnabled || !conf.hasPin,
    );
  }

  bool unlockWithPin(String inputPin) {
    final valid = AppLockService.verifyPin(inputPin, state.config.pinHash);
    if (valid) {
      state = state.copyWith(isUnlocked: true);
    }
    return valid;
  }

  Future<void> setPin(String newPin) async {
    final hashed = AppLockService.hashPin(newPin);
    final updated = state.config.copyWith(
      isEnabled: true,
      pinHash: hashed,
      useBiometrics: false,
    );
    await AppLockService.saveConfig(updated);
    state = state.copyWith(config: updated, isUnlocked: true);
  }

  Future<void> disableLock() async {
    final updated = const AppLockConfig();
    await AppLockService.saveConfig(updated);
    state = state.copyWith(config: updated, isUnlocked: true);
  }

  Future<void> updateTimeout(int minutes) async {
    final updated = state.config.copyWith(timeoutMinutes: minutes);
    await AppLockService.saveConfig(updated);
    state = state.copyWith(config: updated);
  }

  void lockApp() {
    if (state.config.isEnabled && state.config.hasPin) {
      state = state.copyWith(isUnlocked: false);
    }
  }
}
