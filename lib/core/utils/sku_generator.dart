import 'dart:math';

class SkuGenerator {
  SkuGenerator._();

  static String _extractPrefix(String cleanName, String year) {
    if (cleanName.isEmpty) {
      return 'PRD0$year';
    }

    final words = cleanName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (words.length >= 2) {
      final w1 = words[0];
      final w2 = words[1];

      final sub1 = w1.length >= 3 ? w1.substring(0, 3) : w1.padRight(3, '0');
      final sub2 = w2.length >= 3 ? w2.substring(0, 3) : w2.padRight(3, '0');
      return '$sub1$sub2';
    }

    final single = words.first;
    if (single.length >= 6) {
      return single.substring(0, 6);
    } else if (single.length == 5) {
      return '${single.substring(0, 4)}$year';
    } else if (single.length == 4) {
      return '$single$year';
    } else if (single.length == 3) {
      return '${single}0$year';
    } else {
      return single.padRight(4, '0') + year;
    }
  }

  static String generate(String productName, {DateTime? date, Random? random}) {
    final now = date ?? DateTime.now();
    final rng = random ?? Random();
    final year = (now.year % 100).toString().padLeft(2, '0');

    final cleanName = productName
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9\s]'), '')
        .trim();

    final prefix = _extractPrefix(cleanName, year);

    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final dateCode = '$day$month';

    final randomNum = (100 + rng.nextInt(900)).toString();
    final randomLetter = String.fromCharCode(65 + rng.nextInt(26));
    final randomCode = '$randomNum$randomLetter';

    return '$prefix-$dateCode-$randomCode';
  }

  static bool isGeneratedSku(String sku) {
    final trimmed = sku.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[A-Za-z0-9]{3,6}-\d{4,6}-(\d{4}|\d{3}[A-Za-z])$').hasMatch(trimmed);
  }
}
