import '../data_sources/governorate_remote_data_source.dart';
import '../models/governorate_model.dart';

class GovernorateRepository {
  GovernorateRepository(this._remoteDataSource);
  final GovernorateRemoteDataSource _remoteDataSource;

  Future<List<GovernorateModel>> getGovernorates() =>
      _remoteDataSource.getGovernorates();
}
