class VoiceInputResult {
  final String? description;
  final double? amount;

  const VoiceInputResult({this.description, this.amount});
}

class VoiceInputParser {
  static const _stopWords = {
    'рублей', 'рубль', 'рубля', 'руб',
    'долларов', 'доллар', 'доллара', 'баксов',
    'euro', 'евро',
  };

  static const _simpleNumbers = {
    'ноль': 0, 'один': 1, 'одна': 1, 'два': 2, 'две': 2, 'три': 3,
    'четыре': 4, 'пять': 5, 'шесть': 6, 'семь': 7, 'восемь': 8,
    'девять': 9, 'десять': 10, 'одиннадцать': 11, 'двенадцать': 12,
    'тринадцать': 13, 'четырнадцать': 14, 'пятнадцать': 15,
    'шестнадцать': 16, 'семнадцать': 17, 'восемнадцать': 18,
    'девятнадцать': 19, 'двадцать': 20, 'тридцать': 30,
    'сорок': 40, 'пятьдесят': 50, 'шестьдесят': 60,
    'семьдесят': 70, 'восемьдесят': 80, 'девяносто': 90,
    'сто': 100, 'двести': 200, 'триста': 300, 'четыреста': 400,
    'пятьсот': 500, 'шестьсот': 600, 'семьсот': 700,
    'восемьсот': 800, 'девятьсот': 900,
  };

  static const _multipliers = {
    'тысяча': 1000, 'тысячи': 1000, 'тысяч': 1000,
    'миллион': 1000000, 'миллиона': 1000000, 'миллионов': 1000000,
  };

  static VoiceInputResult parse(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return const VoiceInputResult();

    final words = text.split(RegExp(r'\s+'));

    // Try to extract digit-based number first
    final digitMatch = RegExp(r'\d+([.,]\d+)?').firstMatch(text);
    if (digitMatch != null) {
      final numStr = digitMatch.group(0)!.replaceAll(',', '.');
      final amount = double.tryParse(numStr);
      final remaining = text
          .replaceAll(digitMatch.group(0)!, '')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty && !_stopWords.contains(w))
          .join(' ');
      return VoiceInputResult(
        amount: amount,
        description: _capitalize(remaining),
      );
    }

    // Try to extract Russian numeral words
    final numberWords = <String>[];
    final descWords = <String>[];

    for (final word in words) {
      if (_simpleNumbers.containsKey(word) ||
          _multipliers.containsKey(word) ||
          _stopWords.contains(word)) {
        if (!_stopWords.contains(word)) {
          numberWords.add(word);
        }
      } else {
        descWords.add(word);
      }
    }

    if (numberWords.isEmpty) {
      return VoiceInputResult(description: _capitalize(text));
    }

    final amount = _parseRussianNumber(numberWords);
    final desc = descWords.where((w) => w.isNotEmpty).join(' ');

    return VoiceInputResult(
      amount: amount > 0 ? amount.toDouble() : null,
      description: _capitalize(desc),
    );
  }

  static int _parseRussianNumber(List<String> words) {
    int total = 0;
    int current = 0;

    for (final word in words) {
      if (_multipliers.containsKey(word)) {
        final mult = _multipliers[word]!;
        if (current == 0) current = 1;
        total += current * mult;
        current = 0;
      } else if (_simpleNumbers.containsKey(word)) {
        current += _simpleNumbers[word]!;
      }
    }

    return total + current;
  }

  static String? _capitalize(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final trimmed = text.trim();
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}
