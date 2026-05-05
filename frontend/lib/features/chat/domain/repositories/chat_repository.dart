import '../entities/chat_session.dart';

abstract class ChatRepository {
  Future<ChatSession> startChatFromScan({String? scanId});
  Future<ChatSession> sendChatMessage(String sessionId, String content);
}
