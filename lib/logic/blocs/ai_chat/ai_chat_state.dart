import 'package:equatable/equatable.dart';
import '../../../data/models/ai_message_model.dart';

class AIChatState extends Equatable {
  final List<AIMessageModel> messages;
  final bool isSending;
  final String? errorMessage;

  const AIChatState(
      {this.messages = const [], this.isSending = false, this.errorMessage});

  AIChatState copyWith(
      {List<AIMessageModel>? messages,
      bool? isSending,
      String? errorMessage,
      bool clearError = false}) {
    return AIChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [messages, isSending, errorMessage];
}
