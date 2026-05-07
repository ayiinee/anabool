import '../../domain/entities/chat_session.dart';
import '../../domain/entities/chat_cta_card.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../scan/domain/entities/scan_session.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required ChatRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ChatRemoteDatasource _remoteDatasource;

  @override
  Future<ChatSession> startChatFromScan({
    String? scanId,
    ScanSession? scanSession,
  }) {
    return _remoteDatasource.startChatFromScan(
      scanId: scanId,
      scanSession: scanSession,
    );
  }

  @override
  Future<ChatSession> sendChatMessage(String sessionId, String content) {
    return _remoteDatasource.sendChatMessage(sessionId, content);
  }

  @override
  Future<ChatSession> selectCtaCard(String sessionId, ChatCtaCard card) {
    return _remoteDatasource.selectCtaCard(sessionId, card);
  }
}
