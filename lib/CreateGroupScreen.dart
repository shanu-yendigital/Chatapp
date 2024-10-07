import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'GroupChatScreen.dart';

class CreateGroupScreen extends StatefulWidget {
  final String currentUserId;

  CreateGroupScreen({required this.currentUserId});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  List<String> _selectedMembers = [];
  List<dynamic> _groups = [];
  bool _isCreatingGroup = false; //  totrack button state

  Future<void> createGroup(String groupName) async {
    final token = await AuthService().getAccessToken();

    if (groupName.isEmpty) {
      print('Group name cannot be empty');
      return;
    }

    setState(() {
      _isCreatingGroup = true; 
    });

    // Fetch the username for the current user
    final username = await fetchUsername(widget.currentUserId);

    final response = await http.post(
      Uri.parse('http://localhost:5008/api/group/creategroup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'Name': groupName,
        'AdminId': widget.currentUserId,
        'Username': username, 
      }),
    );

    setState(() {
      _isCreatingGroup = false; 
    });

    if (response.statusCode == 200) {
      print("Response from backend: ${response.body}");
      print('Group created successfully');

    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "$groupName" created successfully!'),
          duration: Duration(seconds: 2), 
        ),
      );

      
      await fetchGroups();
    } else {
      print('Failed to create group: ${response.body}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create group: ${response.body}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<String> fetchUsername(String userId) async {
    
    final token = await AuthService().getAccessToken();
    
    final response = await http.get(
      Uri.parse('http://localhost:5008/api/auth/userdetails/$userId'), 
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['username'] ?? 'DefaultUsername'; 
    } else {
      print('Failed to fetch username: ${response.body}');
      return 'DefaultUsername'; 
    }
  }

  Future<void> fetchGroups() async {
    final token = await AuthService().getAccessToken();
    final currentUserId = widget.currentUserId;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/group/getgroups/$currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> groupData = jsonDecode(response.body);

        setState(() {
          _groups = groupData; 
        });

        print("Groups fetched successfully.");
      } else {
        print('Failed to fetch groups: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
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
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: [
            Text(
              'Create a New Group',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), 
            Card(
              elevation: 4, 
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _groupNameController,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16), 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isCreatingGroup
                                ? null
                                : () async {
                                    final groupName = _groupNameController.text;
                                    await createGroup(groupName);
                                  },
                            child: Text(_isCreatingGroup ? 'Creating...' : 'Create Group'),
                          ),
                        ),
                        SizedBox(width: 8), 
                        Expanded(
                          child: ElevatedButton(
                            onPressed: fetchGroups,
                            child: Text('Fetch My Groups'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), 
            Expanded(
              child: _groups.isEmpty
                  ? Center(child: Text('No groups found.'))
                  : ListView.builder(
                      itemCount: _groups.length,
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return ListTile(
                          title: Text(group['name'] ?? 'Unnamed Group'), 
                          subtitle: Text('ID: ${group['id']}'), 
                          onTap: () {
                        
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                  groupId: group['id'],
                                  groupName: group['name'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
