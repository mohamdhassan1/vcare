import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/models/ai_message_model.dart';
import '../../../data/repositories/ai_chat_repository.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  AIChatBloc(this._repository) : super(const AIChatState()) {
    on<AIChatMessageSent>(_onMessageSent);
    on<AIChatRetryRequested>(_onRetryRequested);
    on<AIChatErrorDismissed>(_onErrorDismissed);
  }
  final AIChatRepository _repository;

  Future<void> _onMessageSent(
      AIChatMessageSent event, Emitter<AIChatState> emit) async {
    if (state.isSending) return; // one request at a time
    await _send(event.text, emit);
  }

  Future<void> _onRetryRequested(
      AIChatRetryRequested event, Emitter<AIChatState> emit) async {
    final failed = state.failedMessage;
    if (failed == null || state.isSending) return;
    await _send(failed.text, emit);
  }

  void _onErrorDismissed(
      AIChatErrorDismissed event, Emitter<AIChatState> emit) {
    emit(state.copyWith(
        messages: _answeredOnly(state.messages), clearError: true));
  }

  /// Only answered turns are sent to Gemini: a previously failed user
  /// message would leave a dangling user turn in the history. Since a
  /// failed message is always the last one, dropping it also lets a new
  /// send (or a retry) replace it cleanly.
  List<AIMessageModel> _answeredOnly(List<AIMessageModel> messages) =>
      messages.where((m) => !m.failed).toList();

  Future<void> _send(String text, Emitter<AIChatState> emit) async {
    // Captured BEFORE emitting anything — the true "last known good"
    // conversation to build on. `state.messages` after the emit below
    // would already include the new user message.
    final answered = _answeredOnly(state.messages);
    final userMessage = AIMessageModel(role: AIMessageRole.user, text: text);
    final history = [...answered, userMessage];

    emit(state.copyWith(messages: history, isSending: true, clearError: true));

    try {
      final reply = await _repository.sendMessage(history);
      emit(state.copyWith(messages: [
        ...history,
        AIMessageModel(role: AIMessageRole.model, text: reply)
      ], isSending: false));
    } on AppException catch (e) {
      debugPrint('[AI CHAT] Request failed: ${e.message}');
      _emitFailure(answered, userMessage, AppErrorInfo.from(e), emit);
    } catch (e) {
      debugPrint('[AI CHAT] Unexpected error: $e');
      _emitFailure(answered, userMessage, AppErrorInfo.unknown, emit);
    }
  }

  /// The unanswered message stays on screen, marked failed, next to a
  /// visible error — so the user knows what happened and can retry
  /// without retyping. Nothing is silently dropped.
  void _emitFailure(List<AIMessageModel> answered, AIMessageModel userMessage,
      AppErrorInfo error, Emitter<AIChatState> emit) {
    emit(state.copyWith(
        messages: [...answered, userMessage.copyWith(failed: true)],
        isSending: false,
        error: error));
  }
}
