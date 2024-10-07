import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:frontend/services/auth_service.dart'; 
import 'package:http/http.dart' as http;
import 'chat_screen.dart';
import 'dart:convert';
import 'package:frontend/ui/messages.dart'; 
import 'package:frontend/ui/contacts.dart';
import 'package:frontend/services/auth_service.dart';
import 'CreateGroupScreen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({required this.currentUserId, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> users = []; 
  List<dynamic> groups = []; 

  @override
  void initState() {
    super.initState();
    _fetchUsers(); 
  
  }

  // Function to fetch users from the backend
  Future<void> _fetchUsers() async {
    try {
      final token = await AuthService().getAccessToken(); 
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/auth/users'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> fetchedUsers = jsonDecode(response.body);
          // Filter out the logged-in user from the fetched lists
          users = fetchedUsers.where((user) => user['username'] != widget.currentUserId).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load users')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to log out the user
  void _logout() async {
    await AuthService.logout(context); 
    Navigator.pushReplacementNamed(context, '/login'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          
          Expanded(
            child: ListView(
              children: <Widget>[
                // Contacts List
                ...users.map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[800], 
                    child: Text(
                      user['username'][0].toUpperCase(), 
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user['username']),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'currentUserId': widget.currentUserId, 
                        'targetUserId': user['username'],
                        'chatUserId': user['username'],
                      },
                    );
                  },
                )).toList(),
                
                // Groups List
                ...groups.map((group) => Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen, // Light green color
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      group['Name'],
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Handle group tap if needed
                    },
                  ),
                )).toList(),
              ],
            ),
          ),
          // Create Group Chat button on the right
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                   print("Navigating to CreateGroupScreen with currentUserId: ${widget.currentUserId}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroupScreen(currentUserId: widget.currentUserId),
                    ),
                  );
                },
                child: const Text('Create Group Chat'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
