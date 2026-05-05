import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class StartChatFromScan {
  const StartChatFromScan(this._repository);

  final ChatRepository _repository;

  Future<ChatSession> call({String? scanId}) {
    return _repository.startChatFromScan(scanId: scanId);
  }
}
