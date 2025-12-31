import 'package:intl/intl.dart';

/// Date formatter for Indonesian locale
class DateFormatter {
  DateFormatter._();

  // Indonesian date formats
  static final DateFormat _fullDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _dateOnly = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _timeOnly = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _dayMonth = DateFormat('d MMM', 'id_ID');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoDateTime = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Format to full date with day name
  /// Example: "Senin, 25 Desember 2024"
  static String formatFull(DateTime date) {
    return _fullDate.format(date);
  }

  /// Format to short date
  /// Example: "25 Des 2024"
  static String formatShort(DateTime date) {
    return _shortDate.format(date);
  }

  /// Alias for formatShort
  static String formatShortDate(DateTime date) => formatShort(date);

  /// Format to date only
  /// Example: "25 Desember 2024"
  static String formatDate(DateTime date) {
    return _dateOnly.format(date);
  }

  /// Format to time only
  /// Example: "14:30"
  static String formatTime(DateTime date) {
    return _timeOnly.format(date);
  }

  /// Format to date and time
  /// Example: "25 Des 2024, 14:30"
  static String formatDateTime(DateTime date) {
    return _dateTime.format(date);
  }

  /// Format to month and year
  /// Example: "Desember 2024"
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Format to day and month
  /// Example: "25 Des"
  static String formatDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  /// Format to ISO date
  /// Example: "2024-12-25"
  static String formatIsoDate(DateTime date) {
    return _isoDate.format(date);
  }

  /// Format to ISO datetime
  /// Example: "2024-12-25 14:30:00"
  static String formatIsoDateTime(DateTime date) {
    return _isoDateTime.format(date);
  }

  /// Parse ISO date string to DateTime
  static DateTime? parseIsoDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format relative time (e.g., "2 jam yang lalu")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
    }
  }

  /// Format order date with status
  static String formatOrderDate(DateTime date, {bool showTime = true}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(date.year, date.month, date.day);

    if (orderDay == today) {
      return 'Hari ini${showTime ? ', ${formatTime(date)}' : ''}';
    } else if (orderDay == today.subtract(const Duration(days: 1))) {
      return 'Kemarin${showTime ? ', ${formatTime(date)}' : ''}';
    } else {
      return showTime ? formatDateTime(date) : formatShort(date);
    }
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
