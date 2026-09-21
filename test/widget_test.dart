// Minimal, dependency-free tests for VCare.
//
// Deliberately avoids pumping the full app: `VCareApp` touches
// flutter_secure_storage and the network at startup, which are not
// available in the test environment. Instead we test a leaf widget and
// pure-Dart parsing logic that need no plugins or mocks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vcare/data/models/doctor_model.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('shows label and calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Login',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('shows spinner and is disabled while loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'Login',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });

  group('DoctorModel', () {
    test('listFromJson unwraps the API "data" envelope', () {
      final doctors = DoctorModel.listFromJson({
        'message': 'Success',
        'data': [
          {
            'id': 1,
            'name': 'Dr. Test',
            'specialization': {'id': 3, 'name': 'Cardiology'},
            'city': {'id': 2, 'name': 'Cairo'},
            'appoint_price': 300,
            'start_time': '09:00:00',
            'end_time': '17:00:00',
          },
        ],
      });

      expect(doctors, hasLength(1));
      final doctor = doctors.first;
      expect(doctor.id, 1);
      expect(doctor.name, 'Dr. Test');
      expect(doctor.specialization, 'Cardiology');
      expect(doctor.hospital, 'Cairo');
      expect(doctor.appointPrice, 300);
      expect(doctor.startTime, '09:00');
      expect(doctor.endTime, '17:00');
    });

    test('listFromJson skips non-map items and tolerates missing fields', () {
      final doctors = DoctorModel.listFromJson({
        'data': [
          'not a map',
          {'id': '7'},
        ],
      });

      expect(doctors, hasLength(1));
      expect(doctors.first.id, 7);
      expect(doctors.first.name, 'Doctor');
      expect(doctors.first.specialization, isNull);
    });

    test('listFromJson returns empty list for unexpected payloads', () {
      expect(DoctorModel.listFromJson(null), isEmpty);
      expect(DoctorModel.listFromJson('oops'), isEmpty);
      expect(DoctorModel.listFromJson({'data': {}}), isEmpty);
    });
  });
}
