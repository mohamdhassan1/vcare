import '../data_sources/gemini_remote_data_source.dart';
import '../models/ai_message_model.dart';

class AIChatRepository {
  AIChatRepository(this._remoteDataSource);
  final GeminiRemoteDataSource _remoteDataSource;

  Future<String> sendMessage(List<AIMessageModel> history) =>
      _remoteDataSource.sendMessage(history);
}
