import 'chat_cta_card.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.messageType,
    required this.content,
    required this.createdAt,
    this.cards = const [],
  });

  final String id;
  final String role;
  final String messageType;
  final String content;
  final DateTime createdAt;
  final List<ChatCtaCard> cards;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasCards => messageType == 'cta_cards' && cards.isNotEmpty;
}
