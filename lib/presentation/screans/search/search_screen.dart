import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/presentation/widgets/doctor_card.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../logic/blocs/search/search_bloc.dart';
import '../../../logic/blocs/search/search_event.dart';
import '../../../logic/blocs/search/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SearchOpened());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchBloc>().add(SearchQueryChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Search doctors by name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SearchError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message,
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: AppDimensions.spaceMd),
                          ElevatedButton(
                            onPressed: () => context
                                .read<SearchBloc>()
                                .add(const SearchOpened()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final loaded = state as SearchLoaded;
                  final visible = loaded.visibleDoctors;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _chip(context,
                                label: 'All',
                                selected: loaded.selectedSpecializationId ==
                                    null, onTap: () {
                              context.read<SearchBloc>().add(
                                  const SearchSpecialtyFilterSelected(null));
                            }),
                            const SizedBox(width: AppDimensions.spaceSm),
                            ...loaded.specializations.map((s) => Padding(
                                  padding: const EdgeInsets.only(
                                      right: AppDimensions.spaceSm),
                                  child: _chip(
                                    context,
                                    label: s.name,
                                    selected:
                                        loaded.selectedSpecializationId == s.id,
                                    onTap: () => context.read<SearchBloc>().add(
                                        SearchSpecialtyFilterSelected(s.id)),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      Text('${visible.length} found',
                          style: AppTextStyles.bodySmall),
                      const SizedBox(height: AppDimensions.spaceSm),
                      Expanded(
                        child: visible.isEmpty
                            ? Center(
                                child: Text('No doctors found.',
                                    style: AppTextStyles.bodyMedium))
                            : ListView.builder(
                                itemCount: visible.length,
                                itemBuilder: (context, i) {
                                  final doctor = visible[i];
                                  return DoctorCard(
                                    doctor: doctor,
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.doctorDetails,
                                        arguments: doctor.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.bodySmall
          .copyWith(color: selected ? Colors.white : AppColors.textPrimary),
      backgroundColor: AppColors.surface,
    );
  }
}
