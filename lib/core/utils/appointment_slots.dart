/// LOCAL FALLBACK booking slots.
///
/// The VCare API exposes no doctor-availability endpoint (confirmed
/// absent from the Postman collection). The only booking call is
/// `POST /appointment/store` with `doctor_id`, `start_time`, `notes`,
/// and the server validates the requested time itself. So the dates and
/// times offered in the booking screen are generated on the device to
/// give the user something sensible to pick from — they are NOT the
/// doctor's confirmed availability and must never be labelled as such
/// in the UI. If a slot is actually taken, the server's own validation
/// error surfaces honestly through the normal booking error path.
///
/// Kept in one place so the UI, the request formatting and the tests
/// all agree on the same values.
class AppointmentSlots {
  AppointmentSlots._();

  /// Hour-long slots, 09:00–17:00 with a lunch gap. "HH:mm", 24h.
  static const List<String> fallbackTimeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  /// How many days ahead the date strip offers.
  static const int fallbackDaysAhead = 14;

  /// The selectable dates: the [fallbackDaysAhead] days *after* [from]
  /// (defaults to today), i.e. starting tomorrow — same-day booking is
  /// intentionally not offered. Times are normalised to midnight so two
  /// dates for the same day compare equal.
  static List<DateTime> fallbackDates({DateTime? from}) {
    final today = _dateOnly(from ?? DateTime.now());
    return List<DateTime>.generate(
      fallbackDaysAhead,
      (i) => today.add(Duration(days: i + 1)),
    );
  }

  /// Merges a date from [fallbackDates] with a "HH:mm" slot from
  /// [fallbackTimeSlots] into the DateTime sent to the API.
  static DateTime combine(DateTime date, String slot) {
    final parts = slot.split(':');
    return DateTime(date.year, date.month, date.day, int.parse(parts[0]),
        int.parse(parts[1]));
  }

  /// `start_time` format accepted by POST /appointment/store
  /// (confirmed by a real response): "YYYY-MM-DD HH:mm".
  static String formatStartTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
