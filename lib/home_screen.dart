import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:frontend/services/auth_service.dart'; 
import 'package:http/http.dart' as http;
import 'chat_screen.dart';
import 'dart:convert';
import 'package:frontend/ui/messages.dart'; 
import 'package:frontend/ui/contacts.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

 // Constructor for HomeScreen, requires currentUserId and passes key to the parent class
  HomeScreen({required this.currentUserId, Key? key}) : super(key: key);

  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> users = [];  // List to store fetched users

   @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users when the widget is initialized
   //  _fetchMessages();
  }

   // Function to fetch users from the backend
  Future<void> _fetchUsers() async {
    try {
      
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/auth/users'), // API to fetch all users
        headers: {'Content-Type': 'application/json'}, 
      );

      if (response.statusCode == 200) {
        // If the request is successful (status code 200), update the UI with the fetched users
        setState(() {
        
           List<dynamic> fetchedUsers = jsonDecode(response.body);
          // Filter out the logged-in user from the fetched list
          users = fetchedUsers.where((user) => user['username'] != widget.currentUserId).toList();
        });
      } else {
        // If the request fails, show an error message
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
    await AuthService.logout(context); // Call the AuthService to log out the user
    // Navigate back to the login screen after logout
    Navigator.pushReplacementNamed(context, '/login'); 
  }

  @override

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat list'),
        actions: [
          IconButton(onPressed: _logout, 
          icon: const Icon(Icons.logout),
          ),
        ]
      ),
      
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView.builder(
              itemCount: users.length, // Number of users to display
              itemBuilder: (context, index) {
                final user = users[index]; // Access individual user from the list
                return ListTile(
                  title: Text(user['username']), // Display the username of the user
                  onTap: () {
                   
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'currentUserId': widget.currentUserId, 
                     
                       'targetUserId': user['username'],
                        'chatUserId': user['username'], 
                       // 'chatUserName': user['username'], 
                      },
                    );
                  },


                );
              },
            ),
      
    
    );
  }
} 


// class HomeScreen extends StatefulWidget {
//   final String currentUserId;

//   HomeScreen({required this.currentUserId, Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Home'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Messages'),
//               Tab(text: 'Contacts'),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: _logout,
//             ),
//           ],
//         ),
//         body:  TabBarView(
//           children: [
//             MessagesTab(),
//             ContactsTab(),
//           ],
//         ),
//       ),
//     );
//   }

//   void _logout() async {
    
//   }
// }
