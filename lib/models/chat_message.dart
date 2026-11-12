class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isSystem = false,
    this.orderReference,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isSystem;
  final String? orderReference;
}
