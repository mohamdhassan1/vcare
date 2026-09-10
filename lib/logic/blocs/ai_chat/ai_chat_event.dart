import 'package:equatable/equatable.dart';

abstract class AIChatEvent extends Equatable {
  const AIChatEvent();
  @override
  List<Object?> get props => [];
}

class AIChatMessageSent extends AIChatEvent {
  final String text;
  const AIChatMessageSent(this.text);
  @override
  List<Object?> get props => [text];
}
