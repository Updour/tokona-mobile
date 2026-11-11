import 'dart:math';

class IdGenerator {
  IdGenerator._();

  static final Random _random = Random.secure();

  static String generateId({String prefix = ''}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    final randomPart = List.generate(8, (_) => _random.nextInt(16).toRadixString(16)).join();
    if (prefix.isEmpty) {
      return '$timestamp$randomPart';
    }
    return '$prefix-$timestamp$randomPart';
  }
}
