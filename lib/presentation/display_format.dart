import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';

/// Small presentation-level formatters shared by the doctor and
/// appointment UI, so the same value never looks different on two
/// screens. Nothing here touches API formats.

/// Price for display. The backend sends a bare number and no currency
/// field, so "$" is the documented display currency — not data.
String formatPrice(num price) => '\$$price';

/// Localized appointment status. Only `pending` is confirmed from the
/// backend, so only that one is translated; anything else is shown
/// exactly as the server sent it rather than guessed.
String formatAppointmentStatus(AppLocalizations l10n, String status) =>
    status.trim().toLowerCase() == 'pending' ? l10n.statusPending : status;

/// The two shapes the backend has been seen to use for appointment
/// times, tried in order. Parsing is opportunistic: when neither
/// matches, callers show the raw string, never a made-up date.
final List<DateFormat> _serverTimeFormats = [
  // Confirmed from a real POST /appointment/store response:
  // "Tuesday, September 1, 2026 5:00 PM"
  DateFormat('EEEE, MMMM d, y h:mm a', 'en_US'),
  // The value the app itself sends as start_time.
  DateFormat('yyyy-MM-dd HH:mm', 'en_US'),
];

DateTime? parseServerAppointmentTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim();
  for (final format in _serverTimeFormats) {
    try {
      return format.parseStrict(value);
    } on FormatException {
      // try the next shape
    }
  }
  return null;
}

/// "Tuesday, September 1, 2026" in the active locale.
String formatLongDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toString())
        .format(date);

/// "5:00 PM" / "٥:٠٠ م" in the active locale.
String formatTime(BuildContext context, DateTime date) =>
    DateFormat.jm(Localizations.localeOf(context).toString()).format(date);

/// "September 2026" in the active locale — month context for a strip
/// of day tiles.
String formatMonthYear(BuildContext context, DateTime date) =>
    DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(date);

/// Appointment time for display: localized date + time when the
/// server string is understood, otherwise the server string as-is.
String formatAppointmentTime(BuildContext context, String raw) {
  final parsed = parseServerAppointmentTime(raw);
  if (parsed == null) return raw;
  return '${formatLongDate(context, parsed)} · ${formatTime(context, parsed)}';
}
