// UI Batch 3 — appointments: booking summary + month context + date
// tile cues, success dialog (animated icon, View Appointments), the
// redesigned My Appointments card (AppCard + StatusChip + date row),
// shared price/date formatters, responsive widths.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:vcare/core/routes/app_router.dart';
import 'package:vcare/core/theme/app_dimensions.dart';
import 'package:vcare/core/theme/app_theme.dart';
import 'package:vcare/core/utils/appointment_slots.dart';
import 'package:vcare/data/models/appointment_list_item_model.dart';
import 'package:vcare/data/models/appointment_model.dart';
import 'package:vcare/data/repositories/appointment_repository.dart';
import 'package:vcare/l10n/app_localizations.dart';
import 'package:vcare/l10n/app_localizations_ar.dart';
import 'package:vcare/l10n/app_localizations_en.dart';
import 'package:vcare/logic/blocs/my_appointments/my_appointments_bloc.dart';
import 'package:vcare/presentation/display_format.dart';
import 'package:vcare/presentation/screans/appointments/appointments_screen.dart';
import 'package:vcare/presentation/screans/appointments/book_appointment_screen.dart';
import 'package:vcare/presentation/widgets/app_card.dart';
import 'package:vcare/presentation/widgets/primary_button.dart';
import 'package:vcare/presentation/widgets/status_chip.dart';

// ---------------------------------------------------------------- fakes

class _FakeAppointmentRepository implements AppointmentRepository {
  _FakeAppointmentRepository({this.items = const []});
  final List<AppointmentListItemModel> items;
  final List<String> sentStartTimes = [];
  Completer<AppointmentModel>? gate;

  @override
  Future<List<AppointmentListItemModel>> getAppointments() async => items;

  @override
  Future<AppointmentModel> storeAppointment(
      {required int doctorId, required String startTime, String? notes}) async {
    sentStartTimes.add(startTime);
    if (gate != null) return gate!.future;
    return AppointmentModel(
        id: 1,
        doctorId: doctorId,
        appointmentTime: 'Tuesday, September 1, 2026 5:00 PM',
        status: 'pending');
  }
}

// -------------------------------------------------------------- helpers

final _en = AppLocalizationsEn();
final _ar = AppLocalizationsAr();

Widget _app(Widget home, _FakeAppointmentRepository repo,
        {Locale locale = const Locale('en'),
        ThemeData? theme,
        bool reduceMotion = false}) =>
    RepositoryProvider<AppointmentRepository>.value(
      value: repo,
      child: BlocProvider<MyAppointmentsBloc>(
        create: (_) => MyAppointmentsBloc(repo),
        child: MaterialApp(
          locale: locale,
          theme: theme ?? AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: AppRouter.generateRoute,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
          home: home,
        ),
      ),
    );

const _booking = BookAppointmentScreen(doctorId: 7, doctorName: 'Dr. Heart');

void _useWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('Formatters (M8/M9)', () {
    test('formatPrice is the single "\$" presentation', () {
      expect(formatPrice(300), r'$300');
      expect(formatPrice(49.5), r'$49.5');
    });

    test('server appointment times are parsed when known, else null', () {
      expect(parseServerAppointmentTime('Tuesday, September 1, 2026 5:00 PM'),
          DateTime(2026, 9, 1, 17));
      expect(parseServerAppointmentTime('2026-09-01 17:00'),
          DateTime(2026, 9, 1, 17));
      expect(parseServerAppointmentTime('next tuesday-ish'), isNull);
      expect(parseServerAppointmentTime(''), isNull);
      expect(parseServerAppointmentTime(null), isNull);
    });

    test('status: only pending is localized', () {
      expect(formatAppointmentStatus(_ar, 'Pending'), _ar.statusPending);
      expect(formatAppointmentStatus(_ar, 'rescheduled'), 'rescheduled');
    });
  });

  group('Book Appointment (H6/M9)', () {
    testWidgets(
        'month context, non-color selected date cue, summary only '
        'after a slot is chosen, PrimaryButton CTA', (tester) async {
      final repo = _FakeAppointmentRepository();
      await tester.pumpWidget(_app(_booking, repo));
      await tester.pumpAndSettle();

      final first = AppointmentSlots.fallbackDates().first;
      expect(find.text(DateFormat.yMMMM('en').format(first)), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      // No summary before a time is picked.
      expect(find.text(_en.bookingSummaryTitle), findsNothing);

      // Selected date: semantics selected + bold number.
      final handle = tester.ensureSemantics();
      final firstLabel = DateFormat.yMMMMEEEEd('en').format(first);
      expect(find.bySemanticsLabel(firstLabel), findsOneWidget);
      final day = tester.widget<Text>(find.text('${first.day}').first);
      expect(day.style?.fontWeight, FontWeight.w700);
      handle.dispose();

      await tester.tap(find.text('14:00'));
      await tester.pumpAndSettle();
      expect(find.text(_en.bookingSummaryTitle), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('Dr. Heart'), findsNWidgets(2),
          reason: 'header + summary');
      expect(
          find.text(DateFormat.yMMMMEEEEd('en').format(first)), findsOneWidget);
      expect(find.text(DateFormat.jm('en').format(DateTime(2026, 1, 1, 14))),
          findsOneWidget);
    });

    testWidgets(
        'validation, API format and success dialog with View '
        'Appointments are intact', (tester) async {
      final repo = _FakeAppointmentRepository();
      await tester.pumpWidget(_app(_booking, repo));
      await tester.pumpAndSettle();

      // No slot → localized nudge, nothing sent.
      await tester.ensureVisible(find.text(_en.confirmBooking));
      await tester.tap(find.text(_en.confirmBooking));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(_en.pleaseSelectTimeSlot), findsOneWidget);
      expect(repo.sentStartTimes, isEmpty);
      // Let the floating SnackBar leave so it cannot cover the CTA.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10:00'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(_en.confirmBooking));
      await tester.tap(find.text(_en.confirmBooking));
      await tester.pumpAndSettle();

      final first = AppointmentSlots.fallbackDates().first;
      expect(
          repo.sentStartTimes.single,
          AppointmentSlots.formatStartTime(
              DateTime(first.year, first.month, first.day, 10)),
          reason: 'API start_time format unchanged');

      // Success dialog: honest server-derived message + two actions.
      expect(find.byType(BookingSuccessDialog), findsOneWidget);
      expect(find.text(_en.bookingConfirmed), findsOneWidget);
      expect(
          find.text(_en.bookingScheduledMessage(
              'Dr. Heart', 'Tuesday, September 1, 2026 5:00 PM', 'pending')),
          findsOneWidget);
      expect(find.byType(Transform), findsWidgets, reason: 'icon animated');
      expect(find.text(_en.done), findsOneWidget);
      final view = tester
          .getSize(find.widgetWithText(FilledButton, _en.viewAppointments));
      expect(view.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));

      await tester.tap(find.text(_en.viewAppointments));
      await tester.pumpAndSettle();
      expect(find.byType(BookAppointmentScreen), findsNothing);
      expect(find.byType(AppointmentsScreen), findsOneWidget);
    });

    testWidgets('Done just closes; icon is static under reduced motion',
        (tester) async {
      final repo = _FakeAppointmentRepository();
      await tester.pumpWidget(_app(_booking, repo, reduceMotion: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10:00'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(_en.confirmBooking));
      await tester.tap(find.text(_en.confirmBooking));
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(BookingSuccessDialog),
              matching: find.byType(TweenAnimationBuilder<double>)),
          findsNothing);
      await tester.tap(find.text(_en.done));
      await tester.pumpAndSettle();
      expect(find.byType(BookAppointmentScreen), findsNothing);
      expect(find.byType(AppointmentsScreen), findsNothing);
    });

    testWidgets('Arabic: localized month/date, slots stay LTR digits',
        (tester) async {
      final repo = _FakeAppointmentRepository();
      await tester.pumpWidget(_app(_booking, repo, locale: const Locale('ar')));
      await tester.pumpAndSettle();
      final first = AppointmentSlots.fallbackDates().first;
      expect(find.text(DateFormat.yMMMM('ar').format(first)), findsOneWidget);
      final slot = tester.widget<Text>(find.text('14:00'));
      expect(slot.textDirection, TextDirection.ltr);
      await tester.tap(find.text('14:00'));
      await tester.pumpAndSettle();
      expect(find.text(_ar.bookingSummaryTitle), findsOneWidget);
      expect(find.text(_ar.dateLabel), findsOneWidget);
      expect(find.text(_ar.timeLabel), findsOneWidget);
    });
  });

  group('My Appointments (H7)', () {
    const items = [
      AppointmentListItemModel(
          id: 1,
          doctorName: 'Dr. Heart',
          specialization: 'Cardiology',
          appointmentTime: 'Tuesday, September 1, 2026 5:00 PM',
          status: 'pending',
          price: 300),
      AppointmentListItemModel(
          id: 2,
          doctorName: 'Dr. Tooth',
          appointmentTime: 'sometime soon',
          status: 'rescheduled'),
    ];

    testWidgets(
        'cards use AppCard + StatusChip; date is localized when '
        'parseable and raw otherwise; price via formatPrice', (tester) async {
      await tester.pumpWidget(_app(const AppointmentsScreen(),
          _FakeAppointmentRepository(items: items)));
      await tester.pumpAndSettle();

      expect(find.byType(AppCard), findsNWidgets(2));
      expect(find.byType(StatusChip), findsNWidgets(2));
      expect(find.text(_en.statusPending), findsOneWidget);
      expect(find.text('rescheduled'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      final date = DateTime(2026, 9, 1, 17);
      expect(
          find.text('${DateFormat.yMMMMEEEEd('en').format(date)} · '
              '${DateFormat.jm('en').format(date)}'),
          findsOneWidget);
      expect(find.text('sometime soon'), findsOneWidget, reason: 'raw kept');
      expect(find.text(r'$300'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsNWidgets(2));

      // Date is not smaller than the status pill text.
      final dateText = tester.widget<Text>(find.text('sometime soon'));
      final statusText = tester.widget<Text>(find.text('rescheduled'));
      expect(dateText.style!.fontSize!,
          greaterThanOrEqualTo(statusText.style!.fontSize!));
    });

    testWidgets('Arabic list localizes the parsed date and pending status',
        (tester) async {
      await tester.pumpWidget(_app(
          const AppointmentsScreen(), _FakeAppointmentRepository(items: items),
          locale: const Locale('ar')));
      await tester.pumpAndSettle();
      expect(find.text(_ar.statusPending), findsOneWidget);
      final date = DateTime(2026, 9, 1, 17);
      expect(find.textContaining(DateFormat.yMMMMEEEEd('ar').format(date)),
          findsOneWidget);
    });

    testWidgets(
        'empty state keeps the Browse Doctors action; loading is a '
        'skeleton, not a spinner', (tester) async {
      final repo = _FakeAppointmentRepository();
      await tester.pumpWidget(_app(const AppointmentsScreen(), repo));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text(_en.noAppointmentsYet), findsOneWidget);
      final cta = tester
          .getSize(find.widgetWithText(OutlinedButton, _en.browseDoctors));
      expect(cta.height, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
    });
  });

  group('Responsive', () {
    testWidgets('no overflow at 320px (EN/AR) and 640px cap when wide',
        (tester) async {
      const items = [
        AppointmentListItemModel(
            id: 1,
            doctorName: 'Dr. Very Long Name Indeed For Overflow',
            specialization: 'Cardiology and Cardiovascular Surgery',
            appointmentTime: 'Tuesday, September 1, 2026 5:00 PM',
            status: 'pending',
            price: 300),
      ];
      _useWidth(tester, 320);
      for (final locale in const [Locale('en'), Locale('ar')]) {
        await tester.pumpWidget(
            _app(_booking, _FakeAppointmentRepository(), locale: locale));
        await tester.pumpAndSettle();
        await tester.tap(find.text('14:00'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'booking $locale');

        await tester.pumpWidget(_app(const AppointmentsScreen(),
            _FakeAppointmentRepository(items: items),
            locale: locale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'list $locale');
      }

      _useWidth(tester, 1400);
      await tester.pumpWidget(_app(const AppointmentsScreen(),
          _FakeAppointmentRepository(items: items)));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppCard)).width,
          lessThanOrEqualTo(AppDimensions.contentMaxWidth));
    });
  });
}
