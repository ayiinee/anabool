import '../entities/chat_cta_card.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

class SelectChatCtaCard {
  const SelectChatCtaCard(this._repository);

  final ChatRepository _repository;

  Future<ChatSession> call(ChatSession session, ChatCtaCard card) {
    return _repository.sendChatMessage(
      session.id,
      'Saya pilih ${card.title}. ${card.ctaLabel}.',
    );
  }
}
