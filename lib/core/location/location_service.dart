import 'package:geolocator/geolocator.dart';

/// Why a location lookup failed, in terms the UI can act on.
enum LocationFailure {
  /// GPS / location services are switched off device-wide.
  serviceDisabled,

  /// The user said no this time; asking again is allowed.
  permissionDenied,

  /// The user said "don't ask again" (or policy blocks it). Only the
  /// system settings screen can undo this.
  permissionDeniedForever,

  /// Permission was granted but no fix came back (timeout, no signal).
  unavailable,
}

/// A fix, or the reason there isn't one. Never throws at the caller.
class LocationResult {
  const LocationResult.success(this.latitude, this.longitude) : failure = null;
  const LocationResult.failed(this.failure)
      : latitude = null,
        longitude = null;

  final double? latitude;
  final double? longitude;
  final LocationFailure? failure;

  bool get isSuccess => failure == null;
}

/// The seam the nearest-doctor feature talks to.
///
/// An interface rather than calling Geolocator directly, so the bloc can be
/// tested against every permission outcome without a device or a plugin.
abstract class LocationService {
  /// Asks for permission if needed, then returns a fix or a typed failure.
  Future<LocationResult> getCurrentLocation();

  /// Opens the OS settings page where a "denied forever" choice is undone.
  Future<void> openPermissionSettings();
}

/// The real implementation, backed by the geolocator plugin.
///
/// Foreground location only — nothing here requests background access.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.failed(LocationFailure.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Only prompts when we actually need the fix — never at startup.
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failed(
            LocationFailure.permissionDeniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.failed(LocationFailure.permissionDenied);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationResult.success(position.latitude, position.longitude);
    } catch (_) {
      // Timeout, no signal, plugin missing on an unsupported platform — all
      // mean the same thing to the user: we could not place them.
      return const LocationResult.failed(LocationFailure.unavailable);
    }
  }

  @override
  Future<void> openPermissionSettings() async {
    await Geolocator.openAppSettings();
  }
}
