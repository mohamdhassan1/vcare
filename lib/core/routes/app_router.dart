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
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

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
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case AppRoutes.specializationList:
        return MaterialPageRoute(
            builder: (_) => const SpecializationListScreen());
      case AppRoutes.doctorList:
        return MaterialPageRoute(builder: (_) => const DoctorListScreen());
      case AppRoutes.doctorDetails:
        final doctorId = settings.arguments;
        if (doctorId is! int) {
          return _errorRoute(
              'Doctor Details opened without a valid doctor ID.');
        }
        return MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctorId: doctorId));
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

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(message, textAlign: TextAlign.center)))),
    );
  }
}
