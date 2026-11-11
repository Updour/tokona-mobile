import 'package:flutter/services.dart';

class ProductNameFormatter {
  ProductNameFormatter._();

  static String _capitalizeWordPart(String word) {
    if (word.isEmpty) return '';
    if (word.length == 1) return word.toUpperCase();

    // Preserve common short uppercase abbreviations (e.g. UHT, DUS, PCS, KG, ML, XL)
    if (word == word.toUpperCase() && word.length <= 3 && !RegExp(r'\d').hasMatch(word)) {
      return word;
    }

    final first = word[0].toUpperCase();
    final rest = word == word.toUpperCase() && word.length > 3
        ? word.substring(1).toLowerCase()
        : word.substring(1);
    return '$first$rest';
  }

  static String _formatWord(String word) {
    if (word.isEmpty) return '';
    if (word.contains('-')) {
      return word.split('-').map(_capitalizeWordPart).join('-');
    }
    if (word.contains('/')) {
      return word.split('/').map(_capitalizeWordPart).join('/');
    }
    return _capitalizeWordPart(word);
  }

  /// Converts input string into Title Case and removes duplicate spaces.
  /// If [preserveTrailingSpace] is true, a single trailing space is preserved
  /// to allow typing subsequent words smoothly in text fields.
  static String format(String input, {bool preserveTrailingSpace = false}) {
    if (input.isEmpty) return '';

    // Replace multiple consecutive spaces with a single space
    final collapsed = input.replaceAll(RegExp(r'\s+'), ' ');
    final hasTrailingSpace = collapsed.endsWith(' ');
    final trimmed = collapsed.trim();
    if (trimmed.isEmpty) return '';

    final words = trimmed.split(' ');
    final formattedWords = words.map(_formatWord);
    final result = formattedWords.join(' ');

    if (preserveTrailingSpace && hasTrailingSpace) {
      return '$result ';
    }
    return result;
  }

  /// Trims leading and trailing spaces, collapses multiple internal spaces,
  /// and formats each word to Title Case. Ideal for saving to database.
  static String clean(String input) {
    return format(input, preserveTrailingSpace: false).trim();
  }
}

class ProductNameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Disallow leading spaces
    var text = newValue.text;
    if (text.startsWith(' ')) {
      text = text.trimLeft();
      if (text.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }
    }

    // Collapse multiple consecutive spaces
    final collapsed = text.replaceAll(RegExp(r' {2,}'), ' ');
    final formatted = ProductNameFormatter.format(
      collapsed,
      preserveTrailingSpace: collapsed.endsWith(' '),
    );

    int cursorOffset = newValue.selection.baseOffset;
    if (cursorOffset < 0) {
      cursorOffset = formatted.length;
    } else {
      final diff = newValue.text.length - formatted.length;
      cursorOffset = (cursorOffset - diff).clamp(0, formatted.length);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
