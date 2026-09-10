import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchOpened extends SearchEvent {
  const SearchOpened();
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
