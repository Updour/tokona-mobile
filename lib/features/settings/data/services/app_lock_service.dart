import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tokona/core/utils/password_hasher.dart';
import 'package:tokona/features/settings/domain/models/app_lock_config.dart';

class AppLockService {
  AppLockService._();

  static const String _fileName = 'tokona_app_lock.json';
  static const String _pinSalt = 'tokona_app_lock_security_salt';
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<File> _getFile() async {
    final docsDir = await getApplicationDocumentsDirectory();
    return File(p.join(docsDir.path, _fileName));
  }

  static Future<AppLockConfig> loadConfig() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return const AppLockConfig();
      final content = await file.readAsString();
      if (content.trim().isEmpty) return const AppLockConfig();
      final map = jsonDecode(content) as Map<String, dynamic>;
      return AppLockConfig.fromMap(map);
    } catch (_) {
      return const AppLockConfig();
    }
  }

  static Future<void> saveConfig(AppLockConfig config) async {
    try {
      final file = await _getFile();
      await file.writeAsString(jsonEncode(config.toMap()));
    } catch (_) {}
  }

  static String hashPin(String pin) {
    return PasswordHasher.hashPassword(pin.trim(), _pinSalt);
  }

  static bool verifyPin(String inputPin, String? storedHash) {
    if (storedHash == null || storedHash.isEmpty) return false;
    final hashed = hashPin(inputPin);
    return hashed == storedHash;
  }

  static Future<bool> canUseBiometrics() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics({String reason = 'Pindai sidik jari untuk membuka Tokona POS'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
