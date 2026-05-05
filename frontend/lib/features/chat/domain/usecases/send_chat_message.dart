import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class SendChatMessage {
  const SendChatMessage(this._repository);

  final ChatRepository _repository;

  Future<ChatSession> call(String sessionId, String content) {
    return _repository.sendChatMessage(sessionId, content);
  }
}
