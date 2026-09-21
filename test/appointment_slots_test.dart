// B14 — the booking screen's dates/times are a LOCAL fallback (the API
// has no availability endpoint); these pin down exactly what it offers.

import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/utils/appointment_slots.dart';

void main() {
  group('AppointmentSlots (local fallback, not backend availability)', () {
    test('offers the next 14 days starting tomorrow, at midnight', () {
      final from = DateTime(2026, 9, 19, 15, 42); // afternoon, any time
      final dates = AppointmentSlots.fallbackDates(from: from);

      expect(dates, hasLength(AppointmentSlots.fallbackDaysAhead));
      expect(dates.first, DateTime(2026, 9, 20));
      expect(dates.last, DateTime(2026, 10, 3));
      for (final d in dates) {
        expect(d.hour, 0);
        expect(d.minute, 0);
      }
      expect(dates.any((d) => AppointmentSlots.isSameDay(d, from)), isFalse,
          reason: 'same-day booking is not offered');
    });

    test('time slots are the fixed 09:00–17:00 list with a lunch gap', () {
      expect(AppointmentSlots.fallbackTimeSlots, const [
        '09:00',
        '10:00',
        '11:00',
        '12:00',
        '14:00',
        '15:00',
        '16:00',
        '17:00',
      ]);
      expect(AppointmentSlots.fallbackTimeSlots, isNot(contains('13:00')));
    });

    test('combine + formatStartTime produce the API start_time format', () {
      final dateTime = AppointmentSlots.combine(DateTime(2026, 9, 20), '14:00');
      expect(dateTime, DateTime(2026, 9, 20, 14, 0));
      expect(AppointmentSlots.formatStartTime(dateTime), '2026-09-20 14:00');
      expect(AppointmentSlots.formatStartTime(DateTime(2026, 1, 5, 9, 5)),
          '2026-01-05 09:05');
    });

    test('isSameDay ignores the time of day', () {
      expect(
          AppointmentSlots.isSameDay(
              DateTime(2026, 9, 20, 1), DateTime(2026, 9, 20, 23)),
          isTrue);
      expect(
          AppointmentSlots.isSameDay(
              DateTime(2026, 9, 20), DateTime(2026, 9, 21)),
          isFalse);
    });
  });
}
