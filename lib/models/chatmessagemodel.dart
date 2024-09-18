class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
