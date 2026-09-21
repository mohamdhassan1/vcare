import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchOpened extends SearchEvent {
  /// [specializationId] pre-selects that specialty filter — used when
  /// the screen is opened from a specialty tile (Home / Specialties).
  const SearchOpened({this.specializationId});
  final int? specializationId;
  @override
  List<Object?> get props => [specializationId];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchSpecialtyFilterSelected extends SearchEvent {
  final int? specializationId;
  const SearchSpecialtyFilterSelected(this.specializationId);
  @override
  List<Object?> get props => [specializationId];
}
