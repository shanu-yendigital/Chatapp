
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/chat_screen.dart';

class ContactsTab extends StatefulWidget {
  @override
  _ContactsTabState createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  List<dynamic> users = []; // List to store fetched users

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/auth/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          List<dynamic> fetchedUsers = jsonDecode(response.body);
   
          users = fetchedUsers;
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text(user['username']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  currentUserId: 'currentUserId', 
                  chatUserId: user['username'],
                  targetUserId: user['username'], 
                ),
              ),
            );
          },
        );
      },
    );
  }
}
