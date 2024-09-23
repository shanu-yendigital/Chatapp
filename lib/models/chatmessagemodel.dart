class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
   String readReceipt; 
  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.readReceipt = "sent"
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
     readReceipt: json['readReceipt'] ?? "sent",
    );
  }

Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'readReceipt': readReceipt,
    };
  }
  @override
  String toString() {
    return 'Sender: $senderId, Receiver: $receiverId, Message: $message, Timestamp: $timestamp';
  }
}
