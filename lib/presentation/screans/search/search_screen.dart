import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcare/presentation/widgets/doctor_card.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/search/search_bloc.dart';
import '../../../logic/blocs/search/search_event.dart';
import '../../../logic/blocs/search/search_state.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/skeleton.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialSpecializationId});

  /// Specialty to pre-select when opened from a specialty tile. The
  /// filter is the existing client-side one over the real doctor list
  /// (no "doctors by specialty" endpoint exists), so this is an honest
  /// "show me doctors of this specialty" shortcut, not a new API.
  final int? initialSpecializationId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  /// Marks the pre-selected chip (opened from a specialty tile) so it
  /// can be scrolled into view once the list is first shown.
  final _selectedChipKey = GlobalKey();
  bool _revealedSelectedChip = false;

  @override
  void initState() {
    super.initState();
    context
        .read<SearchBloc>()
        .add(SearchOpened(specializationId: widget.initialSpecializationId));
    // Rebuild so the clear (×) button appears/disappears with the text.
    _controller.addListener(() => setState(() {}));
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

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: ContentConstraint(
          child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchDoctorsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.close,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _clear,
                      ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceMd),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) =>
                    StateSwitcher(child: _results(context, state)),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _revealSelectedChip() {
    if (_revealedSelectedChip) return;
    _revealedSelectedChip = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _selectedChipKey.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(ctx, alignment: 0.5, duration: context.motion());
    });
  }

  Widget _results(BuildContext context, SearchState state) {
    final l10n = context.l10n;
    if (state is SearchLoading) {
      return const SkeletonList(
          itemCount: 4, padding: EdgeInsets.symmetric(vertical: 4));
    }
    if (state is SearchError) {
      return ErrorStateView(
        error: state.error,
        onRetry: () => context.read<SearchBloc>().add(
            SearchOpened(specializationId: widget.initialSpecializationId)),
      );
    }
    final loaded = state as SearchLoaded;
    final visible = loaded.visibleDoctors;
    if (loaded.selectedSpecializationId != null) _revealSelectedChip();
    // One key per (query, filter) so a change cross-fades the whole
    // result area instead of snapping.
    final resultsKey =
        ValueKey('${loaded.query}|${loaded.selectedSpecializationId}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip(context,
                  label: l10n.all,
                  selected: loaded.selectedSpecializationId == null, onTap: () {
                context
                    .read<SearchBloc>()
                    .add(const SearchSpecialtyFilterSelected(null));
              }),
              const SizedBox(width: AppDimensions.spaceSm),
              ...loaded.specializations.map((s) => Padding(
                    // Directional so the gap sits on the
                    // trailing side in RTL as well.
                    padding: const EdgeInsetsDirectional.only(
                        end: AppDimensions.spaceSm),
                    child: _chip(
                      context,
                      key: loaded.selectedSpecializationId == s.id
                          ? _selectedChipKey
                          : null,
                      label: s.name,
                      selected: loaded.selectedSpecializationId == s.id,
                      onTap: () => context
                          .read<SearchBloc>()
                          .add(SearchSpecialtyFilterSelected(s.id)),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        // The empty state below already says "no results" — no double message.
        AnimatedSwitcher(
          duration: context.motion(AppDurations.fast),
          child: visible.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey(visible.length),
                  padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
                  child: Text(l10n.resultsFound(visible.length),
                      style: context.textTheme.bodySmall),
                ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: context.motion(),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [...previous, if (current != null) current],
            ),
            child: visible.isEmpty
                // Echo the query so the user sees what
                // was searched, not just "nothing".
                ? EmptyStateView(
                    key: resultsKey,
                    message: loaded.query.trim().isEmpty
                        ? l10n.noDoctorsFound
                        : l10n.noDoctorsFoundFor(loaded.query.trim()),
                    icon: Icons.search_off_rounded)
                : ListView.builder(
                    key: resultsKey,
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final doctor = visible[i];
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
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context,
      {Key? key,
      required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: context.palette.primary,
      labelStyle: AppTextStyles.bodySmall.copyWith(
          color: selected
              ? context.palette.onPrimary
              : context.palette.textPrimary),
      backgroundColor: context.palette.surface,
    );
  }
}
