import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required ChatRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  final ChatRemoteDatasource _remoteDatasource;

  @override
  Future<ChatSession> startChatFromScan({String? scanId}) {
    return _remoteDatasource.startChatFromScan(scanId: scanId);
  }

  @override
  Future<ChatSession> sendChatMessage(String sessionId, String content) {
    return _remoteDatasource.sendChatMessage(sessionId, content);
  }
}
