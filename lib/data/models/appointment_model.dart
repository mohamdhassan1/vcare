class AppointmentModel {
  final int id;
  final int doctorId;
  final String? doctorName;
  final String? appointmentTime;
  final String? appointmentEndTime;
  final String? status;
  final String? notes;
  final num? price;

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    this.doctorName,
    this.appointmentTime,
    this.appointmentEndTime,
    this.status,
    this.notes,
    this.price,
  });

  /// Confirmed shape from a real POST /appointment/store response:
  /// { "data": { "id":3120, "doctor":{...}, "patient":{...},
  ///   "appointment_time":"Tuesday, September 1, 2026 5:00 PM",
  ///   "appointment_end_time":"...", "status":"pending", "notes":"",
  ///   "appointment_price":300 } }
  factory AppointmentModel.fromJson(dynamic json,
      {required int doctorId, required String startTime, String? notes}) {
    if (json is! Map<String, dynamic> ||
        json['data'] is! Map<String, dynamic>) {
      return AppointmentModel(
          id: 0, doctorId: doctorId, appointmentTime: startTime, notes: notes);
    }
    final data = json['data'] as Map<String, dynamic>;
    final doctor = data['doctor'];
    return AppointmentModel(
      id: int.tryParse('${data['id']}') ?? 0,
      doctorId: doctorId,
      doctorName:
          doctor is Map<String, dynamic> ? doctor['name'] as String? : null,
      appointmentTime: (data['appointment_time'] as String?) ?? startTime,
      appointmentEndTime: data['appointment_end_time'] as String?,
      status: data['status'] as String?,
      notes: (data['notes'] as String?) ?? notes,
      price: data['appointment_price'] is num
          ? data['appointment_price'] as num
          : null,
    );
  }
}
