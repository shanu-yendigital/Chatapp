import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/auth_service.dart'; 

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String chatUserId;
  final String targetUserId;
  const ChatScreen({required this.currentUserId, required this.targetUserId, required this.chatUserId, Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final WebSocketChannel _channel;
  late final Stream _broadcastStream;
  final ImagePicker _picker = ImagePicker();
  //final List<Map<String, String>> messages = [];
  final List<Map<String, dynamic>> messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket(); // Establish WebSocket connection on screen initialization
  }

  @override
  void dispose() {
    _channel.sink.close(); //Close WebSocket connection when the screen is disposed
     print('WebSocket connection closed');
    super.dispose();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
    //  Uri.parse('ws://localhost:5008/ws?userId=${widget.userId}'),
    Uri.parse('ws://localhost:5008/ws?userId=${widget.currentUserId}&chatUserId=${widget.chatUserId}'),
    );


    _broadcastStream = _channel.stream.asBroadcastStream();

  // Listen for incoming messages
    _broadcastStream.listen(
  (message) {
     print('Received WebSocket message: $message');
    if (mounted) {
      final String rawMessage = message.toString();
      final List<String> messageParts = rawMessage.split(':');
      
      if (messageParts.length == 2) {
        final String senderId = messageParts[0];  // Sender's ID (user who sent the message)
        final String messageText = messageParts[1];  // The actual message content

        setState(() {
          messages.add({
            'userId': senderId,
            'message': messageText,
          });
        });
      } else {
        print('Received malformed message: $message');
      }
    }
  },
  onDone: () {
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }
    print('WebSocket connection closed');
  },
  onError: (error) {
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }
    print('WebSocket error: $error');
  },
);

  }
 // Method to send a message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      try {
       //final String messageText = _controller.text;
       final String formattedMessage = "${widget.targetUserId}:${_controller.text}";
            print('Sending message from frontend: $formattedMessage'); 
        _channel.sink.add(formattedMessage); 
        //final DateTime now = DateTime.now();
        setState(() {
          messages.add({
            'userId': widget.currentUserId, 
            
            'message': _controller.text,
            //'message': messageText,
            //'timestamp': now,
          });
        });
        _controller.clear(); // Clear the input field after sending
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {

      print('Picked image: ${image.path}');
    }
  }

 void _logout() async {

    await AuthService.logout(context);

  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${widget.chatUserId} Chat'),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: _logout,
        ),
      ],
    ),
    body: Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final String senderId = msg['userId']; // Extract senderId
              final String messageText = msg['message']; // Extract messageText
               final isSender = msg['userId'] == widget.currentUserId;
              bool isCurrentUser = senderId == widget.currentUserId;

                             return Align(
                  alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.green[800] : Colors.grey[700], 
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      msg['message']!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}