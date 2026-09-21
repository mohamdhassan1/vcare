import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/locale/locale_controller.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

import 'data/data_sources/appointment_remote_data_source.dart';
import 'data/data_sources/auth_remote_data_source.dart';
import 'data/data_sources/city_remote_data_source.dart';
import 'data/data_sources/doctor_remote_data_source.dart';
import 'data/data_sources/favorites_local_data_source.dart';
import 'data/data_sources/gemini_remote_data_source.dart';
import 'data/data_sources/governorate_remote_data_source.dart';
import 'data/data_sources/specialization_remote_data_source.dart';
import 'data/data_sources/user_remote_data_source.dart';

import 'data/repositories/ai_chat_repository.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/city_repository.dart';
import 'data/repositories/doctor_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/governorate_repository.dart';
import 'data/repositories/profile_photo_repository.dart';
import 'data/repositories/specialization_repository.dart';
import 'data/repositories/user_repository.dart';

import 'l10n/app_localizations.dart';

import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/auth/auth_state.dart';
import 'logic/blocs/doctor/doctor_bloc.dart';
import 'logic/blocs/favorites/favorites_bloc.dart';
import 'logic/blocs/favorites/favorites_event.dart';
import 'logic/blocs/favorites/favorites_state.dart';
import 'logic/blocs/home/home_bloc.dart';
import 'logic/blocs/my_appointments/my_appointments_bloc.dart';
import 'logic/blocs/search/search_bloc.dart';
import 'logic/blocs/specialization/specialization_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Persisted preferences are read exactly once, before the first
  // frame, so the app never paints with the wrong theme/locale and
  // never re-reads storage on rebuilds. Both load() calls are
  // non-throwing and time-boxed, so this cannot block startup.
  final localeController = LocaleController(const Locale('en'));
  final themeController = ThemeController(ThemeMode.system);
  await Future.wait([
    localeController.load(),
    themeController.load(),
  ]);

  runApp(VCareApp(
    localeController: localeController,
    themeController: themeController,
  ));
}

class VCareApp extends StatelessWidget {
  const VCareApp({
    super.key,
    required this.localeController,
    required this.themeController,
  });

  final LocaleController localeController;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    final profilePhotoRepository = ProfilePhotoRepository();

    final authRepository = AuthRepository(
      AuthRemoteDataSource(apiClient),
      apiClient.tokenStorage,
      profilePhotoRepository,
      sessionExpired: apiClient.onSessionExpired,
    );

    final userRepository = UserRepository(
      UserRemoteDataSource(apiClient),
      apiClient.tokenStorage,
    );

    final specializationRepository = SpecializationRepository(
      SpecializationRemoteDataSource(apiClient),
    );

    final doctorRepository = DoctorRepository(
      DoctorRemoteDataSource(apiClient),
    );

    final governorateRepository = GovernorateRepository(
      GovernorateRemoteDataSource(apiClient),
    );

    final cityRepository = CityRepository(
      CityRemoteDataSource(apiClient),
    );

    final favoritesRepository = FavoritesRepository(
      FavoritesLocalDataSource(),
      apiClient.tokenStorage,
    );

    final appointmentRepository = AppointmentRepository(
      AppointmentRemoteDataSource(apiClient),
    );

    final aiChatRepository = AIChatRepository(
      GeminiRemoteDataSource(),
    );

    return MultiProvider(
      providers: [
        ListenableProvider<LocaleController>.value(
          value: localeController,
        ),
        ListenableProvider<ThemeController>.value(
          value: themeController,
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(
            create: (_) => authRepository,
          ),
          RepositoryProvider<UserRepository>(
            create: (_) => userRepository,
          ),
          RepositoryProvider<SpecializationRepository>(
            create: (_) => specializationRepository,
          ),
          RepositoryProvider<DoctorRepository>(
            create: (_) => doctorRepository,
          ),
          RepositoryProvider<GovernorateRepository>(
            create: (_) => governorateRepository,
          ),
          RepositoryProvider<CityRepository>(
            create: (_) => cityRepository,
          ),
          RepositoryProvider<FavoritesRepository>(
            create: (_) => favoritesRepository,
          ),
          RepositoryProvider<AppointmentRepository>(
            create: (_) => appointmentRepository,
          ),
          RepositoryProvider<ProfilePhotoRepository>(
            create: (_) => profilePhotoRepository,
          ),
          RepositoryProvider<AIChatRepository>(
            create: (_) => aiChatRepository,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) {
                return AuthBloc(
                  context.read<AuthRepository>(),
                );
              },
            ),
            BlocProvider<HomeBloc>(
              create: (context) {
                return HomeBloc(
                  context.read<UserRepository>(),
                  context.read<SpecializationRepository>(),
                  context.read<DoctorRepository>(),
                );
              },
            ),
            BlocProvider<SpecializationBloc>(
              create: (context) {
                return SpecializationBloc(
                  context.read<SpecializationRepository>(),
                );
              },
            ),
            BlocProvider<DoctorBloc>(
              create: (context) {
                return DoctorBloc(
                  context.read<DoctorRepository>(),
                );
              },
            ),
            BlocProvider<SearchBloc>(
              create: (context) {
                return SearchBloc(
                  context.read<DoctorRepository>(),
                  context.read<SpecializationRepository>(),
                );
              },
            ),
            BlocProvider<FavoritesBloc>(
              create: (context) {
                return FavoritesBloc(
                  context.read<FavoritesRepository>(),
                )..add(const FavoritesStarted());
              },
            ),
            // Shared by the Appointments tab, the pushed route and the
            // booking screen (which refreshes it after a booking). Not
            // started here — AppointmentsScreen loads when it opens.
            BlocProvider<MyAppointmentsBloc>(
              create: (context) {
                return MyAppointmentsBloc(
                  context.read<AppointmentRepository>(),
                );
              },
            ),
          ],
          child: Builder(
            builder: (context) {
              // watch() rebuilds MaterialApp when the user changes a
              // preference; the controllers were already loaded in
              // main(), so nothing is read from storage here.
              final locale = context.watch<LocaleController>();
              final theme = context.watch<ThemeController>();

              // App-level listeners: they sit above the Navigator and
              // use AppRouter.navigatorKey, so they work no matter
              // which screen (if any) triggered the state change.
              return MultiBlocListener(
                listeners: [
                  BlocListener<AuthBloc, AuthState>(
                    listenWhen: (previous, current) =>
                        current is AuthSuccess ||
                        current is AuthLoggedOut ||
                        current is AuthSessionExpired,
                    listener: (context, state) {
                      // The signed-in account changed (or went away):
                      // reload favorites so the in-memory set always
                      // belongs to the current session, never the last.
                      context
                          .read<FavoritesBloc>()
                          .add(const FavoritesStarted());
                      _handleAuthNavigation(state);
                    },
                  ),
                  BlocListener<FavoritesBloc, FavoritesState>(
                    listenWhen: (_, current) => current is FavoritesError,
                    listener: (context, state) =>
                        _showFavoritesError(context, state as FavoritesError),
                  ),
                ],
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  // Brand name is the same in every locale, but going through
                  // l10n keeps the OS/browser title in the l10n system.
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appTitle,
                  navigatorKey: AppRouter.navigatorKey,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: theme.value,
                  locale: locale.value,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('ar'),
                  ],
                  initialRoute: AppRoutes.splash,
                  // One initial route only. Without this, Navigator pushes
                  // "/" *under* "/splash" (path-segment deep-link rule), and
                  // "/" is not a screen — so every shell tab grew a back
                  // arrow that popped to "This page could not be opened".
                  onGenerateInitialRoutes: AppRouter.generateInitialRoutes,
                  onGenerateRoute: AppRouter.generateRoute,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Favorites are device-local, so failures are storage problems the
  /// user can simply retry: reload for a failed load, tap again for a
  /// failed toggle. Shown from here (not per screen) because hearts
  /// appear on Home, Search, Doctors, Details and Favorites alike.
  void _showFavoritesError(BuildContext blocContext, FavoritesError state) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    final l10n = AppLocalizations.of(context);
    final favoritesBloc = blocContext.read<FavoritesBloc>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.type == FavoritesErrorType.loadFailed
            ? l10n.favoritesLoadFailed
            : l10n.favoritesUpdateFailed),
        action: state.type == FavoritesErrorType.loadFailed
            ? SnackBarAction(
                label: l10n.retry,
                onPressed: () => favoritesBloc.add(const FavoritesStarted()),
              )
            : null,
      ),
    );
  }

  void _handleAuthNavigation(AuthState state) {
    // AuthSuccess only needs the favorites reload above; the signed-in
    // screens already navigate to Home themselves.
    if (state is AuthSuccess) return;

    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) return;

    if (state is AuthLoggedOut) {
      // Deliberate logout keeps the existing destination (Onboarding).
      navigator.pushNamedAndRemoveUntil(AppRoutes.onboarding, (route) => false);
    } else if (state is AuthSessionExpired) {
      // Server rejected the token: go straight to Sign In and say why.
      navigator.pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).sessionExpired)),
        );
      }
    }
  }
}
