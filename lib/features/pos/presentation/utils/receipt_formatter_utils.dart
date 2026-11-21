class ReceiptFormatterUtils {
  ReceiptFormatterUtils._();

  /// Memecah teks panjang menjadi beberapa baris yang pas dengan lebar kolom
  static List<String> wrapText(String text, int width) {
    if (text.trim().isEmpty) return [''];
    final words = text.trim().split(RegExp(r'\s+'));
    final lines = <String>[];
    var current = '';

    for (final word in words) {
      if (current.isEmpty) {
        if (word.length > width) {
          var rem = word;
          while (rem.length > width) {
            lines.add(rem.substring(0, width));
            rem = rem.substring(width);
          }
          current = rem;
        } else {
          current = word;
        }
      } else if (current.length + 1 + word.length <= width) {
        current += ' $word';
      } else {
        lines.add(current);
        if (word.length > width) {
          var rem = word;
          while (rem.length > width) {
            lines.add(rem.substring(0, width));
            rem = rem.substring(width);
          }
          current = rem;
        } else {
          current = word;
        }
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines;
  }

  /// Menyelaraskan teks tepat di tengah lebar kolom
  static String center(String text, int width) {
    final t = text.trim();
    if (t.length >= width) return t.substring(0, width);
    final left = (width - t.length) ~/ 2;
    final right = width - t.length - left;
    return '${' ' * left}$t${' ' * right}';
  }

  /// Menyelaraskan teks multi-baris tepat di tengah
  static String centerMultiLine(String text, int width) {
    final lines = wrapText(text, width);
    return lines.map((l) => center(l, width)).join('\n');
  }

  /// Menyelaraskan dua kolom: kiri rata kiri, kanan rata kanan tepat di margin
  static String twoColumn(String left, String right, int width) {
    final cleanRight = right.trim();
    final availForLeft = width - cleanRight.length - 1;

    if (availForLeft <= 0) {
      return '$left\n${' ' * (width - cleanRight.length > 0 ? width - cleanRight.length : 0)}$cleanRight';
    }

    var cleanLeft = left;
    if (cleanLeft.length > availForLeft) {
      cleanLeft = '${cleanLeft.substring(0, availForLeft - 1)}…';
    }

    final spaces = width - cleanLeft.length - cleanRight.length;
    return '$cleanLeft${' ' * (spaces > 0 ? spaces : 1)}$cleanRight';
  }
}
