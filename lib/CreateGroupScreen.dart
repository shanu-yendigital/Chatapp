import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';


class CreateGroupScreen extends StatefulWidget {
  final String currentUserId;

   CreateGroupScreen({required this.currentUserId});
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  List<String> _selectedMembers = []; // You can populate this with selected member IDs
   
  
  Future<void> createGroup(String groupName, List<String> memberIds) async {

    final groupName = _groupNameController.text;
    final adminId = widget.currentUserId; 
    final token = await AuthService().getAccessToken(); // Get access token

    final response = await http.post(
      Uri.parse('http://localhost:5008/api/group/creategroup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'iName': groupName,
        
       'AdminId': adminId,
      
      }),
    );

    if (response.statusCode == 200) {
      // Handle successful group creation
      print("Response from backend: ${response.body}");
      print('Group created successfully');
      // Optionally, navigate back or refresh the UI
    } else {
      // Handle failure
      print('Failed to create group: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: 'Group Name'),
            ),
            // Add your widget to select members
            ElevatedButton(
              onPressed: () async {
                final groupName = _groupNameController.text;
                await createGroup(groupName, _selectedMembers);
                
              },
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
