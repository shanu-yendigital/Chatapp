import 'dart:convert';
import 'package:frontend/models/chatmessagemodel.dart';
import 'package:http/http.dart' as http;


class ChatService {
  final String baseUrl = 'http://localhost:5008/api/chat';  

  
  Future<List<ChatMessage>> fetchMessages(String senderId, String receiverId) async {
    final response = await http.get(Uri.parse('$baseUrl/getMessages?senderId=$senderId&receiverId=$receiverId'));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print('Decoded JSON Data: $data');
      return data.map((message) => ChatMessage.fromJson(message)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Save message to the server
  Future<void> saveMessage(ChatMessage message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sendMessage'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'message': message.message,
        'timestamp': message.timestamp.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print('Message saved successfully');
    } else {
      print('Failed to save message: ${response.body}');
      throw Exception('Failed to save message');
    }
  }
}
