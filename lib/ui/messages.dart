
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessagesTab extends StatefulWidget {
  @override
  _MessagesTabState createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {

  late WebSocketChannel channel;
  
  // List to hold received messages
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }


  void _connectToWebSocket() {
    
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:5008'));


    channel.stream.listen((message) {

      print("Message received: $message");

      setState(() {
        messages.add(message);
      });
    }, onError: (error) {
     
      print("WebSocket error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WebSocket connection error: $error')),
      );
    });
  }

  @override
  void dispose() {

    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: messages.isEmpty
          ? const Center(child: Text('No messages yet'))
          : ListView.builder(
              itemCount: messages.length, 
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]), 
                );
              },
            ),
    );
  }
}
