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
  }
  final AIChatRepository _repository;

  Future<void> _onMessageSent(
      AIChatMessageSent event, Emitter<AIChatState> emit) async {
    // Captured BEFORE emitting anything — this is the true "last known
    // good" state to roll back to on failure. Referencing `state.messages`
    // after the emit below would be wrong, since `state` updates
    // synchronously and would already include the new user message.
    final lastValidMessages = state.messages;

    final userMessage =
        AIMessageModel(role: AIMessageRole.user, text: event.text);
    final uiMessages = [...lastValidMessages, userMessage];
    final requestHistory = [...lastValidMessages, userMessage];

    emit(state.copyWith(
        messages: uiMessages, isSending: true, clearError: true));

    try {
      final reply = await _repository.sendMessage(requestHistory);
      emit(state.copyWith(messages: [
        ...uiMessages,
        AIMessageModel(role: AIMessageRole.model, text: reply)
      ], isSending: false));
    } on AppException catch (e) {
      debugPrint(
          '[AI CHAT] Request failed, rolling back unanswered user turn: ${e.message}');
      // Roll back to the captured pre-emit list — the failed user
      // message disappears from the UI, and the next request's
      // history will not contain a dangling unanswered user turn.
      emit(state.copyWith(
          messages: lastValidMessages,
          isSending: false,
          errorMessage: e.message));
    } catch (e) {
      debugPrint('[AI CHAT] Unexpected error, rolling back: $e');
      emit(state.copyWith(
          messages: lastValidMessages,
          isSending: false,
          errorMessage: 'Something went wrong. Please try again.'));
    }
  }
}
