import 'dart:math' as math;

/// Great-circle distance between two points, and the formatting the UI uses.
///
/// Pure Dart on purpose: no plugin, no device, so the maths and the sorting
/// can be unit-tested without a location provider.
class GeoDistance {
  GeoDistance._();

  /// Mean Earth radius in metres (IUGG). Good to well under 1% for the
  /// short, in-city distances this feature deals with.
  static const double earthRadiusMetres = 6371008.8;

  /// True when a coordinate pair is present and inside the valid ranges:
  /// non-null, finite, latitude within ±90 and longitude within ±180.
  ///
  /// `(0, 0)` is accepted. It is a real position in the Gulf of Guinea, and
  /// nothing in the API marks it as a "missing value" sentinel — the backend
  /// sends `null` for a doctor without a location. Rejecting it would be a
  /// guess, so a doctor genuinely placed there is measured like any other.
  static bool isValidCoordinate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (latitude.isNaN || longitude.isNaN) return false;
    if (latitude.isInfinite || longitude.isInfinite) return false;
    if (latitude < -90 || latitude > 90) return false;
    if (longitude < -180 || longitude > 180) return false;
    return true;
  }

  /// Haversine distance in metres. Returns null if either point is invalid,
  /// so callers can drop unplaceable doctors rather than show a wrong number.
  static double? metresBetween({
    required double? startLatitude,
    required double? startLongitude,
    required double? endLatitude,
    required double? endLongitude,
  }) {
    if (!isValidCoordinate(startLatitude, startLongitude)) return null;
    if (!isValidCoordinate(endLatitude, endLongitude)) return null;

    final lat1 = _toRadians(startLatitude!);
    final lat2 = _toRadians(endLatitude!);
    final deltaLat = _toRadians(endLatitude - startLatitude);
    final deltaLng = _toRadians(endLongitude! - startLongitude!);

    final a = math.pow(math.sin(deltaLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(deltaLng / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMetres * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;
}
