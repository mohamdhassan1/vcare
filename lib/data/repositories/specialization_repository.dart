import '../data_sources/specialization_remote_data_source.dart';
import '../models/specialization_model.dart';

class SpecializationRepository {
  SpecializationRepository(this._remoteDataSource);
  final SpecializationRemoteDataSource _remoteDataSource;

  Future<List<SpecializationModel>> getSpecializations() =>
      _remoteDataSource.getSpecializations();
}
