import 'package:flutter_test/flutter_test.dart';
import 'package:keep_in_track/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('startOfMonth returns 1st of month if startDay is 1', () {
      final date = DateTime(2026, 6, 15);
      final start = DateFormatter.startOfMonth(date, startDay: 1);
      expect(start.year, 2026);
      expect(start.month, 6);
      expect(start.day, 1);
    });

    test('startOfMonth handles custom startDay within current month', () {
      final date = DateTime(2026, 6, 15);
      final start = DateFormatter.startOfMonth(date, startDay: 10);
      expect(start.year, 2026);
      expect(start.month, 6);
      expect(start.day, 10);
    });

    test('startOfMonth handles custom startDay rolling back to previous month', () {
      final date = DateTime(2026, 6, 5);
      final start = DateFormatter.startOfMonth(date, startDay: 10);
      expect(start.year, 2026);
      expect(start.month, 5); // Rolled back to May
      expect(start.day, 10);
    });

    test('startOfMonth handles custom startDay rolling back across years', () {
      final date = DateTime(2026, 1, 5);
      final start = DateFormatter.startOfMonth(date, startDay: 10);
      expect(start.year, 2025); // Rolled back to previous year
      expect(start.month, 12);
      expect(start.day, 10);
    });

    test('endOfMonth returns correct end boundary for startDay 1', () {
      final date = DateTime(2026, 6, 15);
      final end = DateFormatter.endOfMonth(date, startDay: 1);
      expect(end.year, 2026);
      expect(end.month, 6);
      expect(end.day, 30); // June has 30 days
      expect(end.hour, 23);
    });

    test('endOfMonth returns correct boundary across years', () {
      final date = DateTime(2026, 1, 5);
      final end = DateFormatter.endOfMonth(date, startDay: 10);
      // Since date is Jan 5, start is Dec 10, 2025.
      // End should be Jan 9, 2026 at 23:59:59
      expect(end.year, 2026);
      expect(end.month, 1);
      expect(end.day, 9);
      expect(end.hour, 23);
    });

    test('formatRelative returns Today for current day', () {
      final now = DateTime.now();
      expect(DateFormatter.formatRelative(now), 'Today');
    });

    test('formatRelative returns Yesterday for previous day', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      expect(DateFormatter.formatRelative(yesterday), 'Yesterday');
    });

    test('formatRelative returns X days ago for recent dates', () {
      final now = DateTime.now();
      final past = now.subtract(const Duration(days: 4));
      expect(DateFormatter.formatRelative(past), '4 days ago');
    });

    test('formatRelative returns formatted date for older dates', () {
      final now = DateTime.now();
      final older = now.subtract(const Duration(days: 10));
      expect(DateFormatter.formatRelative(older), isNot(contains('days ago')));
    });
  });
}
