import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat(AppConstants.dateFormat);
  static final DateFormat _displayTimeFormat = DateFormat(AppConstants.dateTimeFormat);
  static final DateFormat _monthYearFormat = DateFormat(AppConstants.monthYearFormat);
  static final DateFormat _dayFormat = DateFormat('EEEE, dd MMM');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final DateFormat _weekdayFormat = DateFormat('EEE');
  static final DateFormat _isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// DD MMM YYYY — e.g. "25 May 2026"
  static String format(DateTime date) => _displayFormat.format(date);

  /// DD MMM YYYY, hh:mm AM/PM
  static String formatWithTime(DateTime date) => _displayTimeFormat.format(date);

  /// MMM YYYY — e.g. "May 2026"
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  /// "Monday, 25 May"
  static String formatDay(DateTime date) => _dayFormat.format(date);

  /// "25 May"
  static String formatShort(DateTime date) => _shortDate.format(date);

  /// "Mon", "Tue" etc.
  static String formatWeekday(DateTime date) => _weekdayFormat.format(date);

  /// ISO 8601 string for storage/backup
  static String toIso(DateTime date) => _isoFormat.format(date);

  /// Parse ISO string
  static DateTime fromIso(String iso) => DateTime.parse(iso);

  /// Human-friendly relative: "Today", "Yesterday", "3 days ago", or formatted date
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return format(date);
  }

  /// Returns list of month labels for a given year
  static List<String> monthLabels(int year) {
    return List.generate(12, (i) =>
        _shortDate.format(DateTime(year, i + 1, 1)).substring(3));
  }

  /// Get start of month based on custom start day
  static DateTime startOfMonth(DateTime date, {int startDay = 1}) {
    if (date.day >= startDay) {
      return DateTime(date.year, date.month, startDay);
    } else {
      final prev = DateTime(date.year, date.month - 1, startDay);
      return prev;
    }
  }

  /// Get end of month based on custom start day
  static DateTime endOfMonth(DateTime date, {int startDay = 1}) {
    final start = startOfMonth(date, startDay: startDay);
    return DateTime(start.year, start.month + 1, startDay)
        .subtract(const Duration(microseconds: 1));
  }

  /// Days remaining in current month
  static int daysRemainingInMonth({int startDay = 1}) {
    final now = DateTime.now();
    final end = endOfMonth(now, startDay: startDay);
    return end.difference(DateTime(now.year, now.month, now.day)).inDays + 1;
  }
}
