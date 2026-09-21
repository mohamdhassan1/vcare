enum AIMessageRole { user, model }

class AIMessageModel {
  final AIMessageRole role;
  final String text;

  /// True for a user message the assistant never answered because the
  /// request failed. It stays visible (so the user needn't retype and
  /// can retry) but is excluded from the history sent to Gemini.
  final bool failed;

  const AIMessageModel(
      {required this.role, required this.text, this.failed = false});

  AIMessageModel copyWith({bool? failed}) =>
      AIMessageModel(role: role, text: text, failed: failed ?? this.failed);

  Map<String, dynamic> toGeminiPart() => {
        'role': role == AIMessageRole.user ? 'user' : 'model',
        'parts': [
          {'text': text}
        ],
      };

  @override
  bool operator ==(Object other) =>
      other is AIMessageModel &&
      other.role == role &&
      other.text == text &&
      other.failed == failed;

  @override
  int get hashCode => Object.hash(role, text, failed);
}
