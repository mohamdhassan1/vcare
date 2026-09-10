enum AIMessageRole { user, model }

class AIMessageModel {
  final AIMessageRole role;
  final String text;
  const AIMessageModel({required this.role, required this.text});

  Map<String, dynamic> toGeminiPart() => {
        'role': role == AIMessageRole.user ? 'user' : 'model',
        'parts': [
          {'text': text}
        ],
      };
}
