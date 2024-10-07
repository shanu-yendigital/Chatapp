class GroupMessage {
  final String groupId;
  final String senderId;
  final String message;

  GroupMessage({
    required this.groupId,
    required this.senderId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'GroupId': groupId,
      'SenderId': senderId,
      'Message': message,
    };
  }
}
