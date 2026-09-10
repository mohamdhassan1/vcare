import '../data_sources/city_remote_data_source.dart';
import '../models/city_model.dart';

class CityRepository {
  CityRepository(this._remoteDataSource);
  final CityRemoteDataSource _remoteDataSource;

  Future<List<CityModel>> getCities() => _remoteDataSource.getCities();
  Future<List<CityModel>> getCitiesByGovernorate(int governorateId) =>
      _remoteDataSource.getCitiesByGovernorate(governorateId);
}
