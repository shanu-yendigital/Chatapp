import 'dart:convert';
import 'package:http/http.dart' as http;

class GroupService {
    Future<void> sendMessageToGroup(String groupId, String senderId, String messageText) async {
        final response = await http.post(
            Uri.parse('http://localhost:5008/api/group/sendmessagetogroup'),
            headers: {
                'Content-Type': 'application/json',
            },
            body: jsonEncode({
                'groupId': groupId,
                'senderId': senderId,
                'message': messageText,
            }),
        );

        if (response.statusCode == 200) {
            print('Message sent successfully.');
        } else {
            print('Failed to send message: ${response.body}');
        }
    }
}
