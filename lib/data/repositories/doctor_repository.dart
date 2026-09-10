import '../data_sources/doctor_remote_data_source.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  DoctorRepository(this._remoteDataSource);
  final DoctorRemoteDataSource _remoteDataSource;

  Future<List<DoctorModel>> getDoctors() => _remoteDataSource.getDoctors();
  Future<DoctorModel> getDoctorDetails(int id) =>
      _remoteDataSource.getDoctorDetails(id);
  Future<List<DoctorModel>> searchDoctors(String name) =>
      _remoteDataSource.searchDoctors(name);
}
