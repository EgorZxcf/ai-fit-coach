// mobile/lib/features/chat/models/chat_message.dart

/// Модель сообщения в чате с AI-тренером.
final class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.role,
    required this.text,
    required this.createdAt,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory ChatMessage.user(String text) => ChatMessage(
        role: 'user',
        text: text,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.assistant(String text) => ChatMessage(
        role: 'assistant',
        text: text,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
