import '../../domain/entities/chat_session.dart';
import 'chat_message_model.dart';

class ChatSessionModel extends ChatSession {
  const ChatSessionModel({
    required super.id,
    required super.sessionType,
    required super.assistantName,
    required super.messages,
  });

  factory ChatSessionModel.fromApiResponse(Map<String, dynamic> json) {
    final data = _extractData(json);

    return ChatSessionModel(
      id: _readString(data, 'id'),
      sessionType: _readString(data, 'session_type'),
      assistantName: _readString(data, 'assistant_name'),
      messages: _readMessages(data['messages']),
    );
  }

  static Map<String, dynamic> _extractData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return json;
  }

  static List<ChatMessageModel> _readMessages(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map((item) =>
            ChatMessageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is String ? value : '';
  }
}
