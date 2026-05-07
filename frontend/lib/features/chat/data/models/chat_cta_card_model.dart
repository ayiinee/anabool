import '../../domain/entities/chat_cta_card.dart';

class ChatCtaCardModel extends ChatCtaCard {
  const ChatCtaCardModel({
    required super.cardType,
    required super.title,
    required super.description,
    required super.ctaLabel,
    super.targetRoute,
    super.payload,
  });

  factory ChatCtaCardModel.fromJson(Map<String, dynamic> json) {
    return ChatCtaCardModel(
      cardType: _readString(json, 'card_type'),
      title: _readString(json, 'title'),
      description: _readString(json, 'description'),
      ctaLabel: _readString(json, 'cta_label'),
      targetRoute: _readNullableString(json, 'target_route'),
      payload: _readPayload(json['payload']),
    );
  }

  static Map<String, dynamic> _readPayload(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  static String? _readNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : '';
  }
}
