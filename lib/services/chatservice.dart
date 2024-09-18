import 'dart:convert';
import 'package:frontend/models/chatmessagemodel.dart';
import 'package:http/http.dart' as http;


class ChatService {
  final String baseUrl = 'http://localhost:5008/api/chat/getMessages';  

  // Fetch messages from server
  Future<List<ChatMessage>> fetchMessages(String senderId, String receiverId) async {
    final response = await http.get(Uri.parse('$baseUrl?senderId=$senderId&receiverId=$receiverId'));

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
}