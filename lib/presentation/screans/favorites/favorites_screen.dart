import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/repositories/doctor_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/favorites/favorites_bloc.dart';
import '../../../logic/blocs/favorites/favorites_state.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/skeleton.dart';

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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myFavorites)),
      body: ContentConstraint(
        child: FutureBuilder<List<DoctorModel>>(
          future: _future,
          builder: (context, snapshot) =>
              StateSwitcher(child: _body(context, snapshot)),
        ),
      ),
    );
  }

  Widget _body(
      BuildContext context, AsyncSnapshot<List<DoctorModel>> snapshot) {
    final l10n = context.l10n;
    if (snapshot.connectionState != ConnectionState.done) {
      return const SkeletonList(itemCount: 3);
    }
    if (snapshot.hasError) {
      return ErrorStateView(
        error: AppErrorInfo.from(snapshot.error!),
        onRetry: _refresh,
      );
    }
    final allDoctors = snapshot.data ?? [];
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        final ids = state.favoriteIds;
        final favorites = allDoctors.where((d) => ids.contains(d.id)).toList();
        if (favorites.isEmpty) {
          // Not a dead end: offer the doctor list to save someone.
          return EmptyStateView(
            message: l10n.noFavoritesYet,
            icon: Icons.favorite_border_rounded,
            actionLabel: l10n.browseDoctors,
            onAction: () => Navigator.pushNamed(context, AppRoutes.doctorList),
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
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.doctorDetails, arguments: {
                  'doctorId': doctor.id,
                  'imageUrl': doctor.imageUrl
                }),
              );
            },
          ),
        );
      },
    );
  }
}
