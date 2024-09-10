import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/auth_service.dart'; 

class ChatScreen extends StatefulWidget {
  final String userId;
  final String chatUserId;

  const ChatScreen({required this.userId, required this.chatUserId, Key? key}) : super(key: key);

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
    super.dispose();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:5008/ws?userId=${widget.userId}'),
    );

 // Convert the WebSocket stream to a broadcast stream
    _broadcastStream = _channel.stream.asBroadcastStream();

  // Listen for incoming messages
    _broadcastStream.listen(
      (message) {
        if (mounted) {
          setState(() {
            _isConnected = true;
            messages.add({
              'userId': widget.chatUserId,  // Add received message with sender's ID
              'message': message.toString(),
               //'timestamp': DateTime.now()
            });
          });
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
        _channel.sink.add(_controller.text); // Send message
        //final DateTime now = DateTime.now();
        setState(() {
          messages.add({
            'userId': widget.userId, // Add sent message with current user's ID
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
      // Handle image picking and send image data if needed
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
                //final DateTime timestamp = msg['timestamp'];
                //final String formattedTime = "${timestamp.hour}:${timestamp.minute}";
                return ListTile(
                  title: Row(
                    children: [
                      Text(msg['userId']!),
                      SizedBox(width: 10),
                      
                      Text(msg['message']!),
                      SizedBox(height: 5),
                          // Text(
                          //   formattedTime,
                          //   style: TextStyle(color: Colors.grey, fontSize: 12),
                          // ),
                      if (msg['userId'] == widget.userId)
                        Icon(Icons.check, color: Colors.green),
                    ],
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
