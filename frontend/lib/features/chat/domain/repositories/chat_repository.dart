import '../entities/chat_session.dart';
import '../../../scan/domain/entities/scan_session.dart';

abstract class ChatRepository {
  Future<ChatSession> startChatFromScan({
    String? scanId,
    ScanSession? scanSession,
  });
  Future<ChatSession> sendChatMessage(String sessionId, String content);
}
