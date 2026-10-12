import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/core/errors/app_exception.dart';
import '../../../core/location/location_service.dart';
import '../../../core/utils/geo_distance.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import 'nearest_doctor_event.dart';
import 'nearest_doctor_state.dart';

/// Nearest doctors, computed on the device.
///
/// The dataset is small (a few dozen doctors), so the existing
/// `/doctor/index` response is reused and sorted here rather than adding a
/// location endpoint the documented API contract does not have.
///
/// Order of operations matters: the user's location is requested first, so a
/// denied permission costs nothing and never leaves the screen showing
/// doctors with no distances.
class NearestDoctorBloc extends Bloc<NearestDoctorEvent, NearestDoctorState> {
  NearestDoctorBloc(this._repository, this._locationService)
      : super(const NearestDoctorInitial()) {
    on<NearestDoctorRequested>(_onRequested);
  }

  final DoctorRepository _repository;
  final LocationService _locationService;

  Future<void> _onRequested(
      NearestDoctorRequested event, Emitter<NearestDoctorState> emit) async {
    emit(const NearestDoctorLoading());

    final location = await _locationService.getCurrentLocation();
    if (!location.isSuccess) {
      emit(NearestDoctorLocationUnavailable(location.failure!));
      return;
    }

    try {
      final doctors = await _repository.getDoctors();

      // "No doctors exist" and "no doctor has coordinates" are different
      // problems, so they are reported separately.
      if (doctors.isEmpty) {
        emit(const NearestDoctorNoDoctors());
        return;
      }

      final results = rank(
        doctors: doctors,
        userLatitude: location.latitude,
        userLongitude: location.longitude,
      );

      emit(results.isEmpty
          ? const NearestDoctorEmpty()
          : NearestDoctorLoaded(results));
    } on AppException catch (e) {
      emit(NearestDoctorError(AppErrorInfo.from(e)));
    } catch (_) {
      emit(const NearestDoctorError(AppErrorInfo.unknown));
    }
  }

  /// Measures each doctor and sorts nearest-first.
  ///
  /// Doctors without usable coordinates are dropped rather than pushed to the
  /// end, because the screen's promise is "sorted by distance" and a doctor
  /// with no location has no distance to show.
  ///
  /// Static and pure so it can be tested on its own.
  static List<DoctorWithDistance> rank({
    required List<DoctorModel> doctors,
    required double? userLatitude,
    required double? userLongitude,
  }) {
    final results = <DoctorWithDistance>[];

    for (final doctor in doctors) {
      final metres = GeoDistance.metresBetween(
        startLatitude: userLatitude,
        startLongitude: userLongitude,
        endLatitude: doctor.latitude,
        endLongitude: doctor.longitude,
      );
      if (metres != null) {
        results.add(DoctorWithDistance(doctor, metres));
      }
    }

    results.sort((a, b) => a.distanceMetres.compareTo(b.distanceMetres));
    return results;
  }
}
