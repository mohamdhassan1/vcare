// B5 — booking success refreshes My Appointments from the backend list;
// failures never create a local appointment; refreshes never duplicate.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vcare/core/errors/app_exception.dart';
import 'package:vcare/data/models/appointment_list_item_model.dart';
import 'package:vcare/data/models/appointment_model.dart';
import 'package:vcare/data/repositories/appointment_repository.dart';
import 'package:vcare/logic/blocs/book_appointment/book_appointment_bloc.dart';
import 'package:vcare/logic/blocs/book_appointment/book_appointment_event.dart';
import 'package:vcare/logic/blocs/book_appointment/book_appointment_state.dart';
import 'package:vcare/logic/blocs/my_appointments/my_appointments_bloc.dart';
import 'package:vcare/logic/blocs/my_appointments/my_appointments_event.dart';
import 'package:vcare/logic/blocs/my_appointments/my_appointments_state.dart';

/// Stands in for the backend: `store` appends to the server-side list
/// only when it succeeds; `getAppointments` returns that list.
class _FakeBackend implements AppointmentRepository {
  final List<AppointmentListItemModel> serverList = [];
  final List<String> sentStartTimes = [];
  bool storeShouldFail = false;
  int listCalls = 0;
  Completer<void>? holdList;

  @override
  Future<AppointmentModel> storeAppointment(
      {required int doctorId, required String startTime, String? notes}) async {
    sentStartTimes.add(startTime);
    if (storeShouldFail) throw const ServerException('Slot already taken.');
    final id = serverList.length + 1;
    serverList.add(AppointmentListItemModel(
        id: id, doctorName: 'Dr. $doctorId', appointmentTime: startTime));
    return AppointmentModel(
        id: id,
        doctorId: doctorId,
        appointmentTime: startTime,
        status: 'pending');
  }

  @override
  Future<List<AppointmentListItemModel>> getAppointments() async {
    listCalls++;
    if (holdList != null) await holdList!.future;
    return List.of(serverList);
  }
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _FakeBackend backend;

  setUp(() => backend = _FakeBackend());

  group('BookAppointmentBloc', () {
    test('success comes only from a confirmed server response', () async {
      final bloc = BookAppointmentBloc(backend);
      bloc.add(BookAppointmentSubmitted(
          doctorId: 7, dateTime: DateTime(2026, 9, 21, 9, 0)));
      await _settle();

      expect(bloc.state, isA<BookAppointmentSuccess>());
      expect(backend.sentStartTimes, ['2026-09-21 09:00']);
      expect(backend.serverList, hasLength(1));
      await bloc.close();
    });

    test('failure emits BookAppointmentFailure and stores nothing', () async {
      backend.storeShouldFail = true;
      final bloc = BookAppointmentBloc(backend);
      bloc.add(BookAppointmentSubmitted(
          doctorId: 7, dateTime: DateTime(2026, 9, 21, 9, 0)));
      await _settle();

      expect(bloc.state, isA<BookAppointmentFailure>());
      expect((bloc.state as BookAppointmentFailure).message,
          'Slot already taken.');
      expect(backend.serverList, isEmpty, reason: 'no fake local record');
      await bloc.close();
    });
  });

  group('MyAppointmentsBloc', () {
    test('refresh after a successful booking shows the backend list', () async {
      final list = MyAppointmentsBloc(backend);
      list.add(const MyAppointmentsStarted());
      await _settle();
      expect((list.state as MyAppointmentsLoaded).appointments, isEmpty);

      final booking = BookAppointmentBloc(backend);
      booking.add(BookAppointmentSubmitted(
          doctorId: 7, dateTime: DateTime(2026, 9, 21, 10, 0)));
      await _settle();
      expect(booking.state, isA<BookAppointmentSuccess>());

      // What BookAppointmentScreen dispatches on success.
      list.add(const MyAppointmentsStarted());
      await _settle();
      final loaded = list.state as MyAppointmentsLoaded;
      expect(loaded.appointments, hasLength(1));
      expect(loaded.appointments.single.appointmentTime, '2026-09-21 10:00');

      await booking.close();
      await list.close();
    });

    test('a failed booking leaves the list unchanged after refresh', () async {
      backend.serverList.add(const AppointmentListItemModel(id: 1));
      final list = MyAppointmentsBloc(backend);
      final booking = BookAppointmentBloc(backend);

      backend.storeShouldFail = true;
      booking.add(BookAppointmentSubmitted(
          doctorId: 7, dateTime: DateTime(2026, 9, 21, 10, 0)));
      await _settle();
      list.add(const MyAppointmentsStarted());
      await _settle();

      expect((list.state as MyAppointmentsLoaded).appointments, hasLength(1));
      await booking.close();
      await list.close();
    });

    test('repeated refreshes never duplicate appointments', () async {
      backend.serverList.addAll(const [
        AppointmentListItemModel(id: 1),
        AppointmentListItemModel(id: 2),
      ]);
      final list = MyAppointmentsBloc(backend);
      for (var i = 0; i < 3; i++) {
        list.add(const MyAppointmentsStarted());
        await _settle();
      }
      final ids =
          (list.state as MyAppointmentsLoaded).appointments.map((a) => a.id);
      expect(ids, [1, 2]);
      await list.close();
    });

    test('a refresh requested while one is in flight is not duplicated',
        () async {
      backend.holdList = Completer<void>();
      final list = MyAppointmentsBloc(backend);
      list.add(const MyAppointmentsStarted());
      await _settle();
      list.add(const MyAppointmentsStarted());
      await _settle();
      expect(backend.listCalls, 1);

      backend.holdList!.complete();
      await _settle();
      expect(list.state, isA<MyAppointmentsLoaded>());

      // Once idle, the next refresh goes through.
      list.add(const MyAppointmentsStarted());
      await _settle();
      expect(backend.listCalls, 2);
      await list.close();
    });

    test('a failed refresh reports an error instead of stale success',
        () async {
      final failing = _FailingListBackend();
      final list = MyAppointmentsBloc(failing);
      list.add(const MyAppointmentsStarted());
      await _settle();
      expect(list.state, isA<MyAppointmentsError>());
      expect((list.state as MyAppointmentsError).message,
          'No internet connection.');
      await list.close();
    });
  });
}

class _FailingListBackend implements AppointmentRepository {
  @override
  Future<List<AppointmentListItemModel>> getAppointments() async =>
      throw const NetworkException();

  @override
  Future<AppointmentModel> storeAppointment(
          {required int doctorId, required String startTime, String? notes}) =>
      throw UnimplementedError();
}
