import 'chat_message.dart';

class ChatSession {
  const ChatSession({
    required this.id,
    required this.sessionType,
    required this.assistantName,
    required this.messages,
  });

  final String id;
  final String sessionType;
  final String assistantName;
  final List<ChatMessage> messages;
}
