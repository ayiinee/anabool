import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../../scan/domain/entities/scan_session.dart';

class StartChatFromScan {
  const StartChatFromScan(this._repository);

  final ChatRepository _repository;

  Future<ChatSession> call({
    String? scanId,
    ScanSession? scanSession,
  }) {
    return _repository.startChatFromScan(
      scanId: scanId,
      scanSession: scanSession,
    );
  }
}
