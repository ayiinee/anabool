import '../../domain/entities/chat_message.dart';
import 'chat_cta_card_model.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.role,
    required super.messageType,
    required super.content,
    required super.createdAt,
    super.cards,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _readString(json, 'id'),
      role: _readString(json, 'role'),
      messageType: _readString(json, 'message_type'),
      content: _readString(json, 'content'),
      createdAt: _readDate(json['created_at']),
      cards: _readCards(json['cards']),
    );
  }

  static List<ChatCtaCardModel> _readCards(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) =>
            ChatCtaCardModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static DateTime _readDate(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : '';
  }
}
