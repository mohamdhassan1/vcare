/// All VCare API endpoint paths, taken directly from the Postman
/// collection. Nothing here is invented — if a feature needs an
/// endpoint not listed, it does not exist in the current backend.
class ApiEndpoints {
  ApiEndpoints._();

  // The original host (vcare.integration25.com) no longer resolves — its
  // domain registration lapsed, so DNS returns NXDOMAIN at the apex. This
  // points at the restored VCare API, which serves the same contract.
  // 127.0.0.1 reaches the development machine over `adb reverse tcp:8000
  // tcp:8000`; swap in the machine's LAN address for an untethered demo.
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth Module
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';

  // User Module
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/update';

  // Home Module
  static const String home = '/home/index';

  // Governorate Module
  static const String governorates = '/governrate/index';

  // City Module
  static const String cities = '/city/index';
  static String citiesByGovernorate(int governorateId) =>
      '/city/show/$governorateId';

  // Specialization Module
  static const String specializations = '/specialization/index';
  static String specializationDetails(int id) => '/specialization/show/$id';

  // Doctor Module
  static const String doctors = '/doctor/index';
  static String doctorDetails(int id) => '/doctor/show/$id';
  static const String doctorFilter = '/doctor/doctor-filter';
  static const String doctorSearch = '/doctor/doctor-search';

  // Appointment Module
  static const String appointments = '/appointment/index';
  static const String storeAppointment = '/appointment/store';
}
