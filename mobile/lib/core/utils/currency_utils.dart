class CurrencyUtils {
  static String getSymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'MDL':
        return 'L';
      case 'RON':
        return 'lei';
      case 'JPY':
        return '¥';
      case 'CHF':
        return 'Fr';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      default:
        return currencyCode;
    }
  }

  static String format(double amount, {String currency = 'USD'}) {
    final symbol = getSymbol(currency);
    final formatted = amount.toStringAsFixed(2);
    return '$symbol$formatted';
  }

  static String formatWithSign(double amount, {String currency = 'USD'}) {
    final symbol = getSymbol(currency);
    final formatted = amount.abs().toStringAsFixed(2);
    if (amount >= 0) {
      return '+$symbol$formatted';
    }
    return '-$symbol$formatted';
  }
}
