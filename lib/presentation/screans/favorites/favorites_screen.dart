import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../logic/blocs/favorites/favorites_bloc.dart';
import '../../../logic/blocs/favorites/favorites_state.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<DoctorModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<DoctorRepository>().getDoctors();
  }

  Future<void> _refresh() async {
    setState(() => _future = context.read<DoctorRepository>().getDoctors());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<DoctorModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Something went wrong. Please try again.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppDimensions.spaceMd),
                    ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          final allDoctors = snapshot.data ?? [];
          return BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final ids = state is FavoritesLoaded ? state.favoriteIds : <int>{};
              final favorites = allDoctors.where((d) => ids.contains(d.id)).toList();
              if (favorites.isEmpty) {
                return const EmptyStateView(
                  message: 'No favorites yet.\nTap the heart icon on a doctor to save them here.',
                  icon: Icons.favorite_border_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  itemCount: favorites.length,
                  itemBuilder: (context, i) {
                    final doctor = favorites[i];
                    return DoctorCard(
                      doctor: doctor,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.doctorDetails, arguments: doctor.id),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}