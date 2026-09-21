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

/// Re-sends the message whose request failed (kept in the list marked
/// as failed), without the user having to retype it.
class AIChatRetryRequested extends AIChatEvent {
  const AIChatRetryRequested();
}

/// Drops the failed message and its error banner.
class AIChatErrorDismissed extends AIChatEvent {
  const AIChatErrorDismissed();
}
