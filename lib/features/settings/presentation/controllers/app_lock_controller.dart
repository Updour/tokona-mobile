import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tokona/features/settings/data/services/app_lock_service.dart';
import 'package:tokona/features/settings/domain/models/app_lock_config.dart';

class AppLockState {
  final AppLockConfig config;
  final bool isUnlocked;
  final bool hasBiometricsHardware;

  const AppLockState({
    this.config = const AppLockConfig(),
    this.isUnlocked = false,
    this.hasBiometricsHardware = false,
  });

  bool get isLocked => config.isEnabled && config.hasPin && !isUnlocked;

  AppLockState copyWith({
    AppLockConfig? config,
    bool? isUnlocked,
    bool? hasBiometricsHardware,
  }) {
    return AppLockState(
      config: config ?? this.config,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      hasBiometricsHardware: hasBiometricsHardware ?? this.hasBiometricsHardware,
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
    final canBio = await AppLockService.canUseBiometrics();
    final conf = await AppLockService.loadConfig();
    state = state.copyWith(
      config: conf,
      isUnlocked: !conf.isEnabled || !conf.hasPin,
      hasBiometricsHardware: canBio,
    );
  }

  bool unlockWithPin(String inputPin) {
    final valid = AppLockService.verifyPin(inputPin, state.config.pinHash);
    if (valid) {
      state = state.copyWith(isUnlocked: true);
    }
    return valid;
  }

  Future<bool> unlockWithBiometrics() async {
    if (!state.config.isEnabled || !state.config.useBiometrics) return false;
    final success = await AppLockService.authenticateWithBiometrics(
      reason: 'Pindai sidik jari untuk membuka Tokona POS',
    );
    if (success) {
      state = state.copyWith(isUnlocked: true);
    }
    return success;
  }

  Future<void> setPin(String newPin, {bool useBiometrics = false}) async {
    final hashed = AppLockService.hashPin(newPin);
    final updated = state.config.copyWith(
      isEnabled: true,
      pinHash: hashed,
      useBiometrics: useBiometrics,
    );
    await AppLockService.saveConfig(updated);
    state = state.copyWith(config: updated, isUnlocked: true);
  }

  Future<void> toggleBiometrics(bool enabled) async {
    final updated = state.config.copyWith(useBiometrics: enabled);
    await AppLockService.saveConfig(updated);
    state = state.copyWith(config: updated);
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
