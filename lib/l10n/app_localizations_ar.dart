// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'VCare';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get done => 'تم';

  @override
  String get close => 'إغلاق';

  @override
  String get dismiss => 'تجاهل';

  @override
  String get send => 'إرسال';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmMessage =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى لحجز المواعيد.';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get all => 'الكل';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get browseDoctors => 'تصفح الأطباء';

  @override
  String get somethingWentWrong => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get sessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String featureComingSoon(String feature) {
    return '$feature سيتوفر في تحديث قادم.';
  }

  @override
  String get onboardingHeadline => 'أفضل تطبيق لحجز\nمواعيد الأطباء';

  @override
  String get onboardingSubtitle =>
      'نظّم مواعيدك الطبية واحجزها بسهولة مع VCare لتجربة جديدة.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get signInSubtitle => 'سجّل الدخول لمتابعة حجز المواعيد';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPasswordQuestion => 'هل نسيت كلمة المرور؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get noAccountSignUp => 'ليس لديك حساب؟ أنشئ حساباً';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signUpSubtitle => 'أنشئ حساباً لبدء حجز المواعيد';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get gender => 'النوع';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get haveAccountSignIn => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get forgotPasswordInstructions =>
      'أدخل بريدك الإلكتروني وسنرسل لك تعليمات إعادة تعيين كلمة المرور.';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get passwordResetUnavailable =>
      'إعادة تعيين كلمة المرور غير متاحة حالياً — ستتوفر في تحديث قادم.';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String passwordTooShort(int min) {
    return 'يجب ألا تقل كلمة المرور عن $min أحرف';
  }

  @override
  String get confirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get phoneDigitsOnly => 'يجب أن يحتوي رقم الهاتف على أرقام فقط';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAiAssistant => 'المساعد الذكي';

  @override
  String get navAppointments => 'المواعيد';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get searchDoctors => 'البحث عن أطباء';

  @override
  String get notifications => 'الإشعارات';

  @override
  String homeGreeting(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get homeGreetingNoName => 'مرحباً!';

  @override
  String get howAreYouToday => 'كيف حالك اليوم؟';

  @override
  String get homeBannerTitle => 'احجز موعدك مع\nأقرب طبيب';

  @override
  String get findNearby => 'ابحث بالقرب منك';

  @override
  String get doctorListing => 'قائمة الأطباء';

  @override
  String get doctorSpeciality => 'التخصصات الطبية';

  @override
  String get recommendedDoctors => 'أطباء موصى بهم';

  @override
  String get noDoctorsFound => 'لم يتم العثور على أطباء.';

  @override
  String noDoctorsFoundFor(String query) {
    return 'لم يتم العثور على أطباء لـ \"$query\".';
  }

  @override
  String get noSpecialtiesFound => 'لم يتم العثور على تخصصات.';

  @override
  String get profileUnavailable => 'تعذر تحميل الملف الشخصي.';

  @override
  String get specialtiesUnavailable => 'تعذر تحميل التخصصات.';

  @override
  String get doctorsUnavailable => 'تعذر تحميل الأطباء.';

  @override
  String get search => 'بحث';

  @override
  String get searchDoctorsHint => 'ابحث عن طبيب بالاسم';

  @override
  String resultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String get doctors => 'الأطباء';

  @override
  String get doctorDetails => 'تفاصيل الطبيب';

  @override
  String get workingHours => 'ساعات العمل';

  @override
  String get about => 'نبذة';

  @override
  String get bookAppointment => 'حجز موعد';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تقييم',
      many: '$count تقييماً',
      few: '$count تقييمات',
      two: 'تقييمان',
      one: 'تقييم واحد',
      zero: 'لا توجد تقييمات',
    );
    return '$_temp0';
  }

  @override
  String pricePerVisit(String price) {
    return '$price / الزيارة';
  }

  @override
  String get perVisit => 'للزيارة';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get doctorFallbackName => 'طبيب';

  @override
  String get bookingWith => 'الحجز مع';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get slotsNotConfirmed =>
      'أوقات مقترحة فقط — تؤكد العيادة التوفر عند الحجز.';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get notesHint => 'صف الأعراض أو سبب الزيارة';

  @override
  String get confirmBooking => 'تأكيد الحجز';

  @override
  String get pleaseSelectTimeSlot => 'يرجى اختيار وقت للموعد.';

  @override
  String get bookingConfirmed => 'تم تأكيد الحجز';

  @override
  String get viewAppointments => 'عرض المواعيد';

  @override
  String get bookingSummaryTitle => 'ملخص الموعد';

  @override
  String get doctorLabel => 'الطبيب';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get timeLabel => 'الوقت';

  @override
  String bookingScheduledMessage(
      String doctorName, String time, String status) {
    return 'تم تحديد موعدك مع $doctorName في $time.\nالحالة: $status';
  }

  @override
  String bookingRequestedMessage(String doctorName) {
    return 'تم إرسال طلب موعدك مع $doctorName.';
  }

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get myAppointment => 'مواعيدي';

  @override
  String get noAppointmentsYet => 'ليس لديك مواعيد بعد.';

  @override
  String get myFavorites => 'المفضلة';

  @override
  String get noFavoritesYet =>
      'لا توجد عناصر مفضلة بعد.\nاضغط على رمز القلب عند أي طبيب لحفظه هنا.';

  @override
  String get favoritesLoadFailed => 'تعذر تحميل المفضلة.';

  @override
  String get favoritesUpdateFailed =>
      'تعذر حفظ المفضلة. يرجى المحاولة مرة أخرى.';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePhoto => 'تغيير صورة الملف الشخصي';

  @override
  String get updateProfilePhoto => 'تحديث صورة الملف الشخصي';

  @override
  String get chooseFromGallery => 'اختيار من المعرض';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get removePhoto => 'إزالة الصورة';

  @override
  String get photoLoadFailed => 'تعذر تحميل صورة الملف الشخصي المحفوظة.';

  @override
  String get photoPickFailed => 'تعذر فتح منتقي الصور. يرجى المحاولة مرة أخرى.';

  @override
  String get photoSaveFailed =>
      'تعذر حفظ الصورة على هذا الجهاز. لن يتم الاحتفاظ بها بعد إغلاق التطبيق.';

  @override
  String get photoRemoveFailed => 'تعذر إزالة الصورة. يرجى المحاولة مرة أخرى.';

  @override
  String get medicalRecords => 'السجلات الطبية';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get myTestAndDiagnosis => 'فحوصاتي وتشخيصاتي';

  @override
  String get payment => 'الدفع';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح.';

  @override
  String get pleaseSelectGender => 'يرجى اختيار النوع.';

  @override
  String get accountSection => 'الحساب';

  @override
  String get preferencesSection => 'التفضيلات';

  @override
  String get supportSection => 'الدعم';

  @override
  String get systemDefaultHint => 'يتبع إعداد جهازك';

  @override
  String get sampleContentNotice => 'محتوى تجريبي — غير متصل بعد';

  @override
  String get language => 'اللغة';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get systemDefault => 'حسب النظام';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get security => 'الأمان';

  @override
  String get notificationFromDoctor => 'إشعارات من الطبيب';

  @override
  String get sound => 'الصوت';

  @override
  String get vibrate => 'الاهتزاز';

  @override
  String get specialOffers => 'العروض الخاصة';

  @override
  String get rememberPassword => 'تذكر كلمة المرور';

  @override
  String get faceId => 'بصمة الوجه';

  @override
  String get pin => 'رمز PIN';

  @override
  String get faqQ1 => 'ماذا أتوقع خلال موعدي مع الطبيب؟';

  @override
  String get faqA1 =>
      'سيراجع الطبيب الأعراض والتاريخ المرضي ثم يوصي بالخطوات التالية.';

  @override
  String get faqQ2 => 'كيف أحجز موعداً مع طبيب؟';

  @override
  String get faqA2 =>
      'ابحث عن الأطباء أو تصفّحهم، افتح صفحة الطبيب، ثم اضغط \"حجز موعد\".';

  @override
  String get faqQ3 => 'كم يستغرق الموعد مع الطبيب؟';

  @override
  String get faqA3 => 'تستغرق المواعيد عادةً من 20 إلى 30 دقيقة.';

  @override
  String get notConnected => 'غير مرتبط';

  @override
  String get sampleRecordTitle1 => 'نهاية فترة المتابعة';

  @override
  String get sampleRecordDate1 => '15 فبراير';

  @override
  String get sampleRecordValues1 =>
      'كريات الدم البيضاء: 4.30 مليون/ميكرولتر · الهيموغلوبين: 148 غ/مل';

  @override
  String get sampleRecordTitle2 => 'تحليل الدم';

  @override
  String get sampleRecordDate2 => '25 فبراير';

  @override
  String get sampleRecordValues2 =>
      'كريات الدم الحمراء: 9.30 مليون/ميكرولتر · الهيموغلوبين: 132 غ/مل';

  @override
  String get sampleNotifTitle1 => 'تذكير بالموعد';

  @override
  String get sampleNotifBody1 => 'موعدك يقترب.';

  @override
  String get sampleNotifTime1 => 'منذ ساعتين';

  @override
  String get sampleNotifTitle2 => 'تم تأكيد الحجز';

  @override
  String get sampleNotifBody2 => 'تم استلام طلب موعدك.';

  @override
  String get sampleNotifTime2 => 'منذ يوم';

  @override
  String get sampleNotifTitle3 => 'المفضلة';

  @override
  String get sampleNotifBody3 => 'الأطباء الذين حفظتهم متاحون للحجز.';

  @override
  String get sampleNotifTime3 => 'منذ 3 أيام';

  @override
  String get messages => 'الرسائل';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد.';

  @override
  String get typeAMessage => 'اكتب رسالة';

  @override
  String get aiAssistantTitle => 'مساعد VCare الذكي';

  @override
  String get aiDisclaimer =>
      'إجابات المساعد الذكي للمعلومات العامة فقط ولا تغني عن استشارة الطبيب.';

  @override
  String get aiWelcome => 'مرحباً! اسألني عن VCare أو عن أي سؤال صحي عام.';

  @override
  String get aiInputHint => 'اسأل المساعد الذكي…';

  @override
  String get aiTyping => 'جارٍ الكتابة…';

  @override
  String get aiSuggestionsTitle => 'جرّب أن تسأل';

  @override
  String get you => 'أنت';

  @override
  String get aiSuggestion1 => 'أي طبيب أراجع بسبب الصداع؟';

  @override
  String get aiSuggestion2 => 'كيف أحجز موعداً؟';

  @override
  String get aiSuggestion3 => 'ما هو طبيب القلب؟';

  @override
  String get aiSuggestion4 => 'ساعدني في اختيار التخصص المناسب';

  @override
  String get errorNetwork =>
      'لا يوجد اتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get errorTimeout =>
      'استغرق الطلب وقتاً طويلاً. يرجى المحاولة مرة أخرى.';

  @override
  String get errorServer => 'خطأ في الخادم. يرجى المحاولة لاحقاً.';

  @override
  String get errorNotFound => 'لم يتم العثور على العنصر المطلوب.';

  @override
  String get errorForbidden => 'ليس لديك صلاحية للقيام بذلك.';

  @override
  String get errorTooManyRequests =>
      'طلبات كثيرة جداً. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى.';

  @override
  String get errorBadRequest => 'طلب غير صالح. يرجى التحقق من بياناتك.';

  @override
  String get errorValidation => 'يرجى التحقق من بياناتك والمحاولة مرة أخرى.';

  @override
  String get errorInvalidResponse =>
      'استجابة غير متوقعة من الخادم. يرجى المحاولة مرة أخرى.';

  @override
  String get errorCancelled => 'تم إلغاء الطلب.';

  @override
  String get aiNotConfigured => 'المساعد الذكي غير مُعدّ.';

  @override
  String get aiInvalidKey => 'المساعد الذكي غير متاح حالياً.';

  @override
  String get aiRateLimited =>
      'طلبات كثيرة جداً. يرجى الانتظار قليلاً ثم المحاولة مرة أخرى.';

  @override
  String get aiTimeout =>
      'استغرق المساعد وقتاً طويلاً للرد. يرجى المحاولة مرة أخرى.';

  @override
  String get aiServiceError =>
      'خطأ في خدمة المساعد الذكي. يرجى المحاولة بعد قليل.';

  @override
  String get aiBlocked =>
      'تعذر على المساعد الإجابة عن هذا الطلب. يرجى إعادة صياغته والمحاولة مرة أخرى.';

  @override
  String get aiEmptyResponse =>
      'لم يُرجع المساعد أي رد. يرجى المحاولة مرة أخرى.';

  @override
  String get aiInvalidRequest =>
      'طلب المساعد غير صالح. يرجى المحاولة مرة أخرى.';

  @override
  String get pageCouldNotOpen => 'تعذر فتح هذه الصفحة.';
}
