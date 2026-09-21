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
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get send => 'Send';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmMessage =>
      'You will need to sign in again to book appointments.';

  @override
  String get seeAll => 'See All';

  @override
  String get all => 'All';

  @override
  String get loading => 'Loading';

  @override
  String get browseDoctors => 'Browse Doctors';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String featureComingSoon(String feature) {
    return '$feature is coming in a future update.';
  }

  @override
  String get onboardingHeadline => 'Best Doctor\nAppointment App';

  @override
  String get onboardingSubtitle =>
      'Manage and schedule all of your medical appointments easily with VCare to get a new experience.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInSubtitle => 'Sign in to continue booking appointments';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get login => 'Login';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpSubtitle => 'Sign up to start booking appointments';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get haveAccountSignIn => 'Already have an account? Sign In';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get forgotPasswordInstructions =>
      'Enter your email and we\'ll send you instructions to reset your password.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordResetUnavailable =>
      'Password reset isn\'t available yet — coming in a future update.';

  @override
  String get invalidCredentials => 'Incorrect email or password.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String passwordTooShort(int min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneDigitsOnly => 'Phone must contain numbers only';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get navHome => 'Home';

  @override
  String get navAiAssistant => 'AI Assistant';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchDoctors => 'Search doctors';

  @override
  String get notifications => 'Notifications';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeGreetingNoName => 'Hi there!';

  @override
  String get howAreYouToday => 'How are you today?';

  @override
  String get homeBannerTitle => 'Book and schedule with\nnearest doctor';

  @override
  String get findNearby => 'Find Nearby';

  @override
  String get doctorListing => 'Doctor listing';

  @override
  String get doctorSpeciality => 'Doctor Specialties';

  @override
  String get recommendedDoctors => 'Recommended Doctors';

  @override
  String get noDoctorsFound => 'No doctors found.';

  @override
  String noDoctorsFoundFor(String query) {
    return 'No doctors found for \"$query\".';
  }

  @override
  String get noSpecialtiesFound => 'No specialties found.';

  @override
  String get profileUnavailable => 'Profile could not be loaded.';

  @override
  String get specialtiesUnavailable => 'Specialties could not be loaded.';

  @override
  String get doctorsUnavailable => 'Doctors could not be loaded.';

  @override
  String get search => 'Search';

  @override
  String get searchDoctorsHint => 'Search doctors by name';

  @override
  String resultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results found',
      one: '1 result found',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get doctors => 'Doctors';

  @override
  String get doctorDetails => 'Doctor Details';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get about => 'About';

  @override
  String get bookAppointment => 'Book Appointment';

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String pricePerVisit(String price) {
    return '$price / visit';
  }

  @override
  String get perVisit => 'per visit';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get doctorFallbackName => 'Doctor';

  @override
  String get bookingWith => 'Booking with';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get slotsNotConfirmed =>
      'Suggested times only — the clinic confirms availability when you book.';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'Describe your symptoms or reason for visit';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get pleaseSelectTimeSlot => 'Please select a time slot.';

  @override
  String get bookingConfirmed => 'Booking Confirmed';

  @override
  String get viewAppointments => 'View Appointments';

  @override
  String get bookingSummaryTitle => 'Appointment summary';

  @override
  String get doctorLabel => 'Doctor';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String bookingScheduledMessage(
      String doctorName, String time, String status) {
    return 'Your appointment with $doctorName is scheduled for $time.\nStatus: $status';
  }

  @override
  String bookingRequestedMessage(String doctorName) {
    return 'Your appointment with $doctorName has been requested.';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get myAppointment => 'My Appointments';

  @override
  String get noAppointmentsYet => 'You have no appointments yet.';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get noFavoritesYet =>
      'No favorites yet.\nTap the heart icon on a doctor to save them here.';

  @override
  String get favoritesLoadFailed => 'Your favorites could not be loaded.';

  @override
  String get favoritesUpdateFailed =>
      'Favorite could not be saved. Please try again.';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get changePhoto => 'Change profile photo';

  @override
  String get updateProfilePhoto => 'Update Profile Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get photoLoadFailed => 'Your saved profile photo could not be loaded.';

  @override
  String get photoPickFailed =>
      'Could not open the image picker. Please try again.';

  @override
  String get photoSaveFailed =>
      'The photo could not be saved on this device. It will not be kept after you close the app.';

  @override
  String get photoRemoveFailed =>
      'The photo could not be removed. Please try again.';

  @override
  String get medicalRecords => 'Medical Records';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get myTestAndDiagnosis => 'My Test & Diagnosis';

  @override
  String get payment => 'Payment';

  @override
  String get settings => 'Settings';

  @override
  String get profileUpdated => 'Profile updated successfully.';

  @override
  String get pleaseSelectGender => 'Please select your gender.';

  @override
  String get accountSection => 'Account';

  @override
  String get preferencesSection => 'Preferences';

  @override
  String get supportSection => 'Support';

  @override
  String get systemDefaultHint => 'Follows your device setting';

  @override
  String get sampleContentNotice => 'Sample content — not connected yet';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System Default';

  @override
  String get faq => 'FAQ';

  @override
  String get security => 'Security';

  @override
  String get notificationFromDoctor => 'Notification from Doctor';

  @override
  String get sound => 'Sound';

  @override
  String get vibrate => 'Vibrate';

  @override
  String get specialOffers => 'Special Offers';

  @override
  String get rememberPassword => 'Remember password';

  @override
  String get faceId => 'Face ID';

  @override
  String get pin => 'PIN';

  @override
  String get faqQ1 => 'What should I expect during a doctor\'s appointment?';

  @override
  String get faqA1 =>
      'Your doctor will review your symptoms and history, then advise next steps.';

  @override
  String get faqQ2 => 'How do I make an appointment with a doctor?';

  @override
  String get faqA2 =>
      'Search or browse doctors, open their profile, and tap Book Appointment.';

  @override
  String get faqQ3 => 'How long will my doctor\'s appointment take?';

  @override
  String get faqA3 => 'Typical appointments run 20–30 minutes.';

  @override
  String get notConnected => 'Not connected';

  @override
  String get sampleRecordTitle1 => 'End of observation';

  @override
  String get sampleRecordDate1 => 'Feb 15';

  @override
  String get sampleRecordValues1 =>
      'White blood cell: 4.30 million/uL · Hemoglobin: 148 g/mL';

  @override
  String get sampleRecordTitle2 => 'Blood Analysis';

  @override
  String get sampleRecordDate2 => 'Feb 25';

  @override
  String get sampleRecordValues2 =>
      'Red blood cell: 9.30 million/uL · Hemoglobin: 132 g/mL';

  @override
  String get sampleNotifTitle1 => 'Appointment Reminder';

  @override
  String get sampleNotifBody1 => 'Your appointment is coming up soon.';

  @override
  String get sampleNotifTime1 => '2h ago';

  @override
  String get sampleNotifTitle2 => 'Booking Confirmed';

  @override
  String get sampleNotifBody2 => 'Your appointment request was received.';

  @override
  String get sampleNotifTime2 => '1d ago';

  @override
  String get sampleNotifTitle3 => 'Favorites';

  @override
  String get sampleNotifBody3 => 'Doctors you saved are available for booking.';

  @override
  String get sampleNotifTime3 => '3d ago';

  @override
  String get messages => 'Messages';

  @override
  String get noMessagesYet => 'No messages yet.';

  @override
  String get typeAMessage => 'Type a message';

  @override
  String get aiAssistantTitle => 'VCare AI Assistant';

  @override
  String get aiDisclaimer =>
      'AI responses are for general information and do not replace professional medical advice.';

  @override
  String get aiWelcome =>
      'Hi! Ask me anything about VCare or general health questions.';

  @override
  String get aiInputHint => 'Ask the AI Assistant…';

  @override
  String get aiTyping => 'Typing…';

  @override
  String get aiSuggestionsTitle => 'Try asking';

  @override
  String get you => 'You';

  @override
  String get aiSuggestion1 => 'Which doctor should I see for a headache?';

  @override
  String get aiSuggestion2 => 'How can I book an appointment?';

  @override
  String get aiSuggestion3 => 'What is a cardiologist?';

  @override
  String get aiSuggestion4 => 'Help me find the right specialty';

  @override
  String get errorNetwork =>
      'No internet connection. Please check your connection and try again.';

  @override
  String get errorTimeout => 'The request took too long. Please try again.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorNotFound => 'The requested item was not found.';

  @override
  String get errorForbidden => 'You do not have permission to do that.';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get errorBadRequest =>
      'Invalid request. Please check your information.';

  @override
  String get errorValidation => 'Please check your information and try again.';

  @override
  String get errorInvalidResponse =>
      'Unexpected response from the server. Please try again.';

  @override
  String get errorCancelled => 'The request was cancelled.';

  @override
  String get aiNotConfigured => 'AI Assistant is not configured.';

  @override
  String get aiInvalidKey => 'AI Assistant is unavailable right now.';

  @override
  String get aiRateLimited =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String get aiTimeout =>
      'The assistant took too long to respond. Please try again.';

  @override
  String get aiServiceError => 'AI service error. Please try again shortly.';

  @override
  String get aiBlocked =>
      'The assistant could not answer that request. Please rephrase and try again.';

  @override
  String get aiEmptyResponse =>
      'The assistant did not return a response. Please try again.';

  @override
  String get aiInvalidRequest =>
      'The AI request was invalid. Please try again.';

  @override
  String get pageCouldNotOpen => 'This page could not be opened.';
}
