import 'package:intl/intl.dart';

/// Currency formatter for Indonesian Rupiah
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format number to Rupiah currency string
  /// Example: 150000 -> "Rp 150.000"
  static String format(num amount) {
    return _rupiahFormat.format(amount);
  }

  /// Format to compact notation
  /// Example: 1500000 -> "Rp 1,5 jt"
  static String formatCompact(num amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(1)} rb';
    }
    return format(amount);
  }

  /// Parse Rupiah string back to number
  /// Example: "Rp 150.000" -> 150000
  static double parse(String formattedAmount) {
    final cleanedString = formattedAmount
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleanedString) ?? 0;
  }

  /// Format with discount percentage
  /// Example: formatWithDiscount(100000, 80000) -> "Rp 80.000 (20% off)"
  static String formatWithDiscount(num originalPrice, num discountedPrice) {
    if (originalPrice <= discountedPrice) {
      return format(originalPrice);
    }
    
    final discountPercent = ((originalPrice - discountedPrice) / originalPrice * 100).round();
    return '${format(discountedPrice)} ($discountPercent% off)';
  }

  /// Format price range
  /// Example: formatRange(10000, 50000) -> "Rp 10.000 - Rp 50.000"
  static String formatRange(num minPrice, num maxPrice) {
    return '${format(minPrice)} - ${format(maxPrice)}';
  }
}
