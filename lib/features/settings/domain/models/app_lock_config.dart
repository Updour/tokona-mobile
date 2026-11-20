class AppLockConfig {
  final bool isEnabled;
  final String? pinHash;
  final bool useBiometrics;

  const AppLockConfig({
    this.isEnabled = false,
    this.pinHash,
    this.useBiometrics = false,
  });

  bool get hasPin => pinHash != null && pinHash!.isNotEmpty;

  AppLockConfig copyWith({
    bool? isEnabled,
    String? pinHash,
    bool? useBiometrics,
  }) {
    return AppLockConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      pinHash: pinHash ?? this.pinHash,
      useBiometrics: useBiometrics ?? this.useBiometrics,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_enabled': isEnabled,
      'pin_hash': pinHash,
      'use_biometrics': useBiometrics,
    };
  }

  factory AppLockConfig.fromMap(Map<String, dynamic> map) {
    return AppLockConfig(
      isEnabled: (map['is_enabled'] as bool?) ?? false,
      pinHash: map['pin_hash'] as String?,
      useBiometrics: (map['use_biometrics'] as bool?) ?? false,
    );
  }
}
