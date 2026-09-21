import 'package:flutter/material.dart';
import 'package:vcare/presentation/screans/appointments/appointments_screen.dart';
import 'package:vcare/presentation/screans/appointments/book_appointment_screen.dart';
import 'package:vcare/presentation/screans/auth/forgot_password_screen.dart';
import 'package:vcare/presentation/screans/auth/sign_in_screen.dart';
import 'package:vcare/presentation/screans/auth/sign_up_screen.dart';
import 'package:vcare/presentation/screans/doctor/doctor_details_screen.dart';
import 'package:vcare/presentation/screans/doctor/doctor_list_screen.dart';
import 'package:vcare/presentation/screans/favorites/favorites_screen.dart';
import 'package:vcare/presentation/screans/home/home_shell_screen.dart';
import 'package:vcare/presentation/screans/notifications/notifications_screen.dart';
import 'package:vcare/presentation/screans/onboarding/onboarding_screen.dart';
import 'package:vcare/presentation/screans/search/search_screen.dart';
import 'package:vcare/presentation/screans/specialization/specialization_list_screen.dart';
import 'package:vcare/presentation/screans/splash/splash_screen.dart';
import '../../l10n/l10n.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  /// Attached to [MaterialApp.navigatorKey] so app-level logic that
  /// lives above the Navigator (e.g. the auth listener in main.dart)
  /// can route through the same named-route system as the screens.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// The app always starts on Splash, whatever the platform reports as
  /// the initial route name ("/" on web, "/splash" from [initialRoute]).
  /// Returning exactly one route keeps the stack root clean: the shell
  /// that replaces Splash must have nothing to pop back to.
  static List<Route<dynamic>> generateInitialRoutes(String initialRoute) => [
        MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.splash),
            builder: (_) => const SplashScreen()),
      ];

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case AppRoutes.myAppointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeShellScreen());
      case AppRoutes.search:
        // Optional int argument: a specialty id to pre-filter by.
        final specializationId = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => SearchScreen(
                initialSpecializationId:
                    specializationId is int ? specializationId : null));
      case AppRoutes.specializationList:
        return MaterialPageRoute(
            builder: (_) => const SpecializationListScreen());
      case AppRoutes.doctorList:
        return MaterialPageRoute(builder: (_) => const DoctorListScreen());
      case AppRoutes.doctorDetails:
        // Accepts the doctor id alone, or {doctorId, imageUrl} so the
        // details header can show the photo (and finish the Hero flight)
        // before the details request completes.
        final args = settings.arguments;
        final int? doctorId = args is int
            ? args
            : (args is Map && args['doctorId'] is int
                ? args['doctorId'] as int
                : null);
        if (doctorId == null) {
          return _errorRoute(
              'Doctor Details opened without a valid doctor ID.');
        }
        final imageUrl = args is Map && args['imageUrl'] is String
            ? args['imageUrl'] as String
            : null;
        return MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(
                doctorId: doctorId, initialImageUrl: imageUrl));
      case AppRoutes.bookAppointment:
        final args = settings.arguments;
        if (args is! Map<String, dynamic> ||
            args['doctorId'] is! int ||
            args['doctorName'] is! String) {
          return _errorRoute(
              'Booking opened without valid doctor information.');
        }
        return MaterialPageRoute(
          builder: (_) => BookAppointmentScreen(
              doctorId: args['doctorId'] as int,
              doctorName: args['doctorName'] as String),
        );
      case AppRoutes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return _errorRoute('No route defined for "${settings.name}"');
    }
  }

  /// [debugReason] is developer diagnostics (logged, never shown); the
  /// user sees a localized, generic message with a way back.
  static Route<dynamic> _errorRoute(String debugReason) {
    debugPrint('[ROUTER] $debugReason');
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.l10n.pageCouldNotOpen,
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
