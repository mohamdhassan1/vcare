import 'package:equatable/equatable.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/ai_message_model.dart';

class AIChatState extends Equatable {
  /// Full conversation as shown on screen. May end with one user
  /// message marked `failed` (never answered).
  final List<AIMessageModel> messages;
  final bool isSending;

  /// Set when the last request failed. Cleared only by an explicit
  /// action — retry, dismiss, or sending a new message — never by an
  /// unrelated state update, so the user always gets to read it. The
  /// UI localizes it from [AppErrorInfo.code].
  final AppErrorInfo? error;

  const AIChatState(
      {this.messages = const [], this.isSending = false, this.error});

  /// English fallback text of [error] (logs/tests).
  String? get errorMessage => error?.message;

  /// The unanswered message the user can retry, if any.
  AIMessageModel? get failedMessage {
    if (messages.isEmpty) return null;
    final last = messages.last;
    return last.failed ? last : null;
  }

  bool get hasError => error != null;

  AIChatState copyWith(
      {List<AIMessageModel>? messages,
      bool? isSending,
      AppErrorInfo? error,
      bool clearError = false}) {
    return AIChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [messages, isSending, error];
}
