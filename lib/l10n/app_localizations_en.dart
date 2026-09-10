// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VCare';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get howAreYouToday => 'How Are you Today?';

  @override
  String get seeAll => 'See All';

  @override
  String get retry => 'Retry';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Profile';

  @override
  String get myAppointment => 'My Appointment';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get settings => 'Settings';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String get search => 'Search';

  @override
  String get noDoctorsFound => 'No doctors found.';

  @override
  String get noSpecialtiesFound => 'No specialties found.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';
}
