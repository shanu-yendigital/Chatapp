import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/group_service.dart'; 

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupChatScreen({required this.groupId, required this.groupName});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];
  List<dynamic> availableContacts = []; // List to store contacts fetched from the database
  String? selectedContact; // Store the selected contact for adding to the group
  final GroupService _groupService = GroupService(); 
  List<Map<String, dynamic>> members = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableContacts(); 
    _fetchGroupMembers(); 
  }

  // Function to fetch available contacts from the backend
  Future<void> _fetchAvailableContacts() async {
    final token = await AuthService().getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/auth/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> contactsData = jsonDecode(response.body);

        setState(() {
          availableContacts = contactsData;
        });
        print("Available Contacts: $availableContacts");
        print("Contacts fetched successfully.");
      } else {
        print('Failed to fetch contacts: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to fetch group members
  Future<void> _fetchGroupMembers() async {
    final token = await AuthService().getAccessToken();
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/group/getgroupmembers/${widget.groupId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> membersData = jsonDecode(response.body);

        print("Fetched group data for groupId: ${widget.groupId}");
        print(membersData); 
        
        setState(() {
          members = membersData.map((member) {
            return {
              'UserId': member['userId'],
              'Username': member['username'],
            };
          }).toList();
        });
        print('Group members fetched: $members');
      } else {
        print('Failed to fetch group members: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to start group chat
  void _startGroupChat() {
    print("Starting group chat with members: $members");
   
  }

  // Function to send a message to the group
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text.trim();
      String senderId = "sender_id"; 
      setState(() {
        messages.add(messageText); 
      });

      // Call the sendMessageToGroup function from the GroupService
      await _groupService.sendMessageToGroup(widget.groupId, senderId, messageText);
      _messageController.clear(); // Clear the message input field
    }
  }

  // Function to add a selected contact to the group
  void _addContactToGroup() async {
    if (selectedContact != null) {
      final token = await AuthService().getAccessToken();

      final selectedContactData = availableContacts.firstWhere((contact) {
        final contactId =
            '${contact['id']['timestamp']}-${contact['id']['increment']}';
        return contactId == selectedContact; 
      }, orElse: () => null); 
      String? username;
      if (selectedContactData != null) {
        username = selectedContactData['username']; 
      }

      try {
        final response = await http.post(
          Uri.parse('http://localhost:5008/api/group/addusertogroup'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'GroupId': widget.groupId,
            'UserId': selectedContact,
            'Name': null,
            'Username': username, 
          }),
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            members.add({
              'UserId': selectedContact!,
              'Username': username ?? 'Unknown', 
            });
          });
          print('Contact added to group');
        } else {
          print('Failed to add contact: ${response.body}');
        }
      } catch (e) {
        print('Error while adding contact: $e');
      }
    } else {
      print('No contact selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Members:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 40.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: members.length,
              itemBuilder: (context, index) {
                return Chip(
                  label: Text(members[index]['Username'] ?? 'Unknown'), 
                );
              },
            ),
          ),
          // Button to start group chat
          ElevatedButton(
            onPressed: _startGroupChat,
            child: Text('Start Group Chat'),
          ),
          // Chat messages section
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                availableContacts.isNotEmpty
                    ? DropdownButton<String>(
                        hint: Text('Select a contact'),
                        value: selectedContact,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedContact = newValue; 
                          });
                        },
                        items: availableContacts.map<DropdownMenuItem<String>>((contact) {
                          final contactId =
                              '${contact['id']['timestamp']}-${contact['id']['increment']}';
                          return DropdownMenuItem<String>(
                            value: contactId,
                            child: Text(contact['username'] ?? 'Unknown'),
                          );
                        }).toList(),
                      )
                    : CircularProgressIndicator(), 
                ElevatedButton(
                  onPressed: _addContactToGroup,
                  child: Text('Add Contact to Group'),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Send a message',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

