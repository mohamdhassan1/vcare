import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// App name shown in the OS task switcher / browser tab. Brand name, same in every language.
  ///
  /// In en, this message translates to:
  /// **'VCare'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to book appointments.'**
  String get logoutConfirmMessage;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Screen-reader label for progress indicators and skeleton placeholders.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @browseDoctors.
  ///
  /// In en, this message translates to:
  /// **'Browse Doctors'**
  String get browseDoctors;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming in a future update.'**
  String featureComingSoon(String feature);

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Best Doctor\nAppointment App'**
  String get onboardingHeadline;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage and schedule all of your medical appointments easily with VCare to get a new experience.'**
  String get onboardingSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue booking appointments'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get noAccountSignUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to start booking appointments'**
  String get signUpSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get haveAccountSignIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you instructions to reset your password.'**
  String get forgotPasswordInstructions;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password reset isn\'t available yet — coming in a future update.'**
  String get passwordResetUnavailable;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalidCredentials;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordTooShort(int min);

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Phone must contain numbers only'**
  String get phoneDigitsOnly;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get navAiAssistant;

  /// No description provided for @navAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppointments;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @searchDoctors.
  ///
  /// In en, this message translates to:
  /// **'Search doctors'**
  String get searchDoctors;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingNoName.
  ///
  /// In en, this message translates to:
  /// **'Hi there!'**
  String get homeGreetingNoName;

  /// No description provided for @howAreYouToday.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get howAreYouToday;

  /// No description provided for @homeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Book and schedule with\nnearest doctor'**
  String get homeBannerTitle;

  /// No description provided for @findNearby.
  ///
  /// In en, this message translates to:
  /// **'Find Nearby'**
  String get findNearby;

  /// No description provided for @doctorListing.
  ///
  /// In en, this message translates to:
  /// **'Doctor listing'**
  String get doctorListing;

  /// No description provided for @doctorSpeciality.
  ///
  /// In en, this message translates to:
  /// **'Doctor Specialties'**
  String get doctorSpeciality;

  /// No description provided for @recommendedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Recommended Doctors'**
  String get recommendedDoctors;

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found.'**
  String get noDoctorsFound;

  /// No description provided for @noDoctorsFoundFor.
  ///
  /// In en, this message translates to:
  /// **'No doctors found for \"{query}\".'**
  String noDoctorsFoundFor(String query);

  /// No description provided for @noSpecialtiesFound.
  ///
  /// In en, this message translates to:
  /// **'No specialties found.'**
  String get noSpecialtiesFound;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be loaded.'**
  String get profileUnavailable;

  /// No description provided for @specialtiesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Specialties could not be loaded.'**
  String get specialtiesUnavailable;

  /// No description provided for @doctorsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Doctors could not be loaded.'**
  String get doctorsUnavailable;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchDoctorsHint.
  ///
  /// In en, this message translates to:
  /// **'Search doctors by name'**
  String get searchDoctorsHint;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result found} other{{count} results found}}'**
  String resultsFound(int count);

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @doctorDetails.
  ///
  /// In en, this message translates to:
  /// **'Doctor Details'**
  String get doctorDetails;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String reviewsCount(int count);

  /// No description provided for @pricePerVisit.
  ///
  /// In en, this message translates to:
  /// **'{price} / visit'**
  String pricePerVisit(String price);

  /// Caption under the price in the booking bar.
  ///
  /// In en, this message translates to:
  /// **'per visit'**
  String get perVisit;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @doctorFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorFallbackName;

  /// No description provided for @bookingWith.
  ///
  /// In en, this message translates to:
  /// **'Booking with'**
  String get bookingWith;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @slotsNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Suggested times only — the clinic confirms availability when you book.'**
  String get slotsNotConfirmed;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptoms or reason for visit'**
  String get notesHint;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @pleaseSelectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Please select a time slot.'**
  String get pleaseSelectTimeSlot;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get bookingConfirmed;

  /// No description provided for @viewAppointments.
  ///
  /// In en, this message translates to:
  /// **'View Appointments'**
  String get viewAppointments;

  /// No description provided for @bookingSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Appointment summary'**
  String get bookingSummaryTitle;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @bookingScheduledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your appointment with {doctorName} is scheduled for {time}.\nStatus: {status}'**
  String bookingScheduledMessage(String doctorName, String time, String status);

  /// No description provided for @bookingRequestedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your appointment with {doctorName} has been requested.'**
  String bookingRequestedMessage(String doctorName);

  /// Fallback appointment status shown only when the backend omits one.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @myAppointment.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get myAppointment;

  /// No description provided for @noAppointmentsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no appointments yet.'**
  String get noAppointmentsYet;

  /// No description provided for @myFavorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get myFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.\nTap the heart icon on a doctor to save them here.'**
  String get noFavoritesYet;

  /// No description provided for @favoritesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your favorites could not be loaded.'**
  String get favoritesLoadFailed;

  /// No description provided for @favoritesUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Favorite could not be saved. Please try again.'**
  String get favoritesUpdateFailed;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changePhoto;

  /// No description provided for @updateProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Photo'**
  String get updateProfilePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @photoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Your saved profile photo could not be loaded.'**
  String get photoLoadFailed;

  /// No description provided for @photoPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the image picker. Please try again.'**
  String get photoPickFailed;

  /// No description provided for @photoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be saved on this device. It will not be kept after you close the app.'**
  String get photoSaveFailed;

  /// No description provided for @photoRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be removed. Please try again.'**
  String get photoRemoveFailed;

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Medical Records'**
  String get medicalRecords;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @myTestAndDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'My Test & Diagnosis'**
  String get myTestAndDiagnosis;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdated;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender.'**
  String get pleaseSelectGender;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @preferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesSection;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @systemDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your device setting'**
  String get systemDefaultHint;

  /// Caption on screens whose content is illustrative only (no backend behind it).
  ///
  /// In en, this message translates to:
  /// **'Sample content — not connected yet'**
  String get sampleContentNotice;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @notificationFromDoctor.
  ///
  /// In en, this message translates to:
  /// **'Notification from Doctor'**
  String get notificationFromDoctor;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get vibrate;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember password'**
  String get rememberPassword;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'What should I expect during a doctor\'s appointment?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Your doctor will review your symptoms and history, then advise next steps.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I make an appointment with a doctor?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Search or browse doctors, open their profile, and tap Book Appointment.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How long will my doctor\'s appointment take?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Typical appointments run 20–30 minutes.'**
  String get faqA3;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @sampleRecordTitle1.
  ///
  /// In en, this message translates to:
  /// **'End of observation'**
  String get sampleRecordTitle1;

  /// No description provided for @sampleRecordDate1.
  ///
  /// In en, this message translates to:
  /// **'Feb 15'**
  String get sampleRecordDate1;

  /// No description provided for @sampleRecordValues1.
  ///
  /// In en, this message translates to:
  /// **'White blood cell: 4.30 million/uL · Hemoglobin: 148 g/mL'**
  String get sampleRecordValues1;

  /// No description provided for @sampleRecordTitle2.
  ///
  /// In en, this message translates to:
  /// **'Blood Analysis'**
  String get sampleRecordTitle2;

  /// No description provided for @sampleRecordDate2.
  ///
  /// In en, this message translates to:
  /// **'Feb 25'**
  String get sampleRecordDate2;

  /// No description provided for @sampleRecordValues2.
  ///
  /// In en, this message translates to:
  /// **'Red blood cell: 9.30 million/uL · Hemoglobin: 132 g/mL'**
  String get sampleRecordValues2;

  /// No description provided for @sampleNotifTitle1.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get sampleNotifTitle1;

  /// No description provided for @sampleNotifBody1.
  ///
  /// In en, this message translates to:
  /// **'Your appointment is coming up soon.'**
  String get sampleNotifBody1;

  /// No description provided for @sampleNotifTime1.
  ///
  /// In en, this message translates to:
  /// **'2h ago'**
  String get sampleNotifTime1;

  /// No description provided for @sampleNotifTitle2.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed'**
  String get sampleNotifTitle2;

  /// No description provided for @sampleNotifBody2.
  ///
  /// In en, this message translates to:
  /// **'Your appointment request was received.'**
  String get sampleNotifBody2;

  /// No description provided for @sampleNotifTime2.
  ///
  /// In en, this message translates to:
  /// **'1d ago'**
  String get sampleNotifTime2;

  /// No description provided for @sampleNotifTitle3.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get sampleNotifTitle3;

  /// No description provided for @sampleNotifBody3.
  ///
  /// In en, this message translates to:
  /// **'Doctors you saved are available for booking.'**
  String get sampleNotifBody3;

  /// No description provided for @sampleNotifTime3.
  ///
  /// In en, this message translates to:
  /// **'3d ago'**
  String get sampleNotifTime3;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeAMessage;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'VCare AI Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI responses are for general information and do not replace professional medical advice.'**
  String get aiDisclaimer;

  /// No description provided for @aiWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! Ask me anything about VCare or general health questions.'**
  String get aiWelcome;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI Assistant…'**
  String get aiInputHint;

  /// No description provided for @aiTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing…'**
  String get aiTyping;

  /// No description provided for @aiSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Try asking'**
  String get aiSuggestionsTitle;

  /// Screen-reader label for the user's own chat messages.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @aiSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Which doctor should I see for a headache?'**
  String get aiSuggestion1;

  /// No description provided for @aiSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'How can I book an appointment?'**
  String get aiSuggestion2;

  /// No description provided for @aiSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'What is a cardiologist?'**
  String get aiSuggestion3;

  /// No description provided for @aiSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'Help me find the right specialty'**
  String get aiSuggestion4;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item was not found.'**
  String get errorNotFound;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get errorForbidden;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errorTooManyRequests;

  /// No description provided for @errorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your information.'**
  String get errorBadRequest;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your information and try again.'**
  String get errorValidation;

  /// No description provided for @errorInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from the server. Please try again.'**
  String get errorInvalidResponse;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled.'**
  String get errorCancelled;

  /// No description provided for @aiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant is not configured.'**
  String get aiNotConfigured;

  /// No description provided for @aiInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant is unavailable right now.'**
  String get aiInvalidKey;

  /// No description provided for @aiRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get aiRateLimited;

  /// No description provided for @aiTimeout.
  ///
  /// In en, this message translates to:
  /// **'The assistant took too long to respond. Please try again.'**
  String get aiTimeout;

  /// No description provided for @aiServiceError.
  ///
  /// In en, this message translates to:
  /// **'AI service error. Please try again shortly.'**
  String get aiServiceError;

  /// No description provided for @aiBlocked.
  ///
  /// In en, this message translates to:
  /// **'The assistant could not answer that request. Please rephrase and try again.'**
  String get aiBlocked;

  /// No description provided for @aiEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'The assistant did not return a response. Please try again.'**
  String get aiEmptyResponse;

  /// No description provided for @aiInvalidRequest.
  ///
  /// In en, this message translates to:
  /// **'The AI request was invalid. Please try again.'**
  String get aiInvalidRequest;

  /// No description provided for @pageCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'This page could not be opened.'**
  String get pageCouldNotOpen;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
