import '../entities/chat_session.dart';
import '../entities/chat_cta_card.dart';
import '../../../scan/domain/entities/scan_session.dart';

abstract class ChatRepository {
  Future<ChatSession> startChatFromScan({
    String? scanId,
    ScanSession? scanSession,
  });
  Future<ChatSession> sendChatMessage(String sessionId, String content);
  Future<ChatSession> selectCtaCard(String sessionId, ChatCtaCard card);
}
