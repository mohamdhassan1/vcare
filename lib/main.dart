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
import 'logic/blocs/doctor/doctor_bloc.dart';
import 'logic/blocs/favorites/favorites_bloc.dart';
import 'logic/blocs/favorites/favorites_event.dart';
import 'logic/blocs/home/home_bloc.dart';
import 'logic/blocs/search/search_bloc.dart';
import 'logic/blocs/specialization/specialization_bloc.dart';

void main() {
  runApp(const VCareApp());
}

class VCareApp extends StatelessWidget {
  const VCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    final profilePhotoRepository = ProfilePhotoRepository();

    final authRepository = AuthRepository(
      AuthRemoteDataSource(apiClient),
      apiClient.tokenStorage,
      profilePhotoRepository,
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
    );

    final appointmentRepository = AppointmentRepository(
      AppointmentRemoteDataSource(apiClient),
    );

    final aiChatRepository = AIChatRepository(
      GeminiRemoteDataSource(),
    );

    final localeController = LocaleController(
      const Locale('en'),
    );

    final themeController = ThemeController(
      ThemeMode.system,
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
          ],
          child: Builder(
            builder: (context) {
              final locale = context.watch<LocaleController>();
              final theme = context.watch<ThemeController>();

              return FutureBuilder(
                future: Future.wait([
                  locale.load(),
                  theme.load(),
                ]),
                builder: (context, snapshot) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'VCare',
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
                    onGenerateRoute: AppRouter.generateRoute,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
