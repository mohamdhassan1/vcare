// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'في كير';

  @override
  String homeGreeting(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get howAreYouToday => 'كيف حالك اليوم؟';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get myAppointment => 'مواعيدي';

  @override
  String get myFavorites => 'المفضلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get bookAppointment => 'حجز موعد';

  @override
  String get search => 'بحث';

  @override
  String get noDoctorsFound => 'لم يتم العثور على أطباء.';

  @override
  String get noSpecialtiesFound => 'لم يتم العثور على تخصصات.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما. حاول مرة أخرى.';
}
