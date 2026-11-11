import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  static final Random _random = Random.secure();

  static String generateSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hashPassword(String password, String salt) {
    final saltedPassword = '$password:$salt';
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    final computedHash = hashPassword(password, salt);
    return computedHash == expectedHash;
  }
}
