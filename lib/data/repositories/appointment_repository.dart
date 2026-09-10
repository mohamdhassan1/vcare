import '../data_sources/appointment_remote_data_source.dart';
import '../models/appointment_list_item_model.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  AppointmentRepository(this._remoteDataSource);
  final AppointmentRemoteDataSource _remoteDataSource;

  Future<AppointmentModel> storeAppointment(
      {required int doctorId, required String startTime, String? notes}) {
    return _remoteDataSource.storeAppointment(
        doctorId: doctorId, startTime: startTime, notes: notes);
  }

  Future<List<AppointmentListItemModel>> getAppointments() =>
      _remoteDataSource.getAppointments();
}
