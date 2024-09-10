import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'package:frontend/services/auth_service.dart'; 
import 'package:http/http.dart' as http;

import 'dart:convert';
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
  }

   // Function to fetch users from the backend
  Future<void> _fetchUsers() async {
    try {
      // Making a GET request to the backend API to retrieve the list of users
      final response = await http.get(
        Uri.parse('http://localhost:5008/api/auth/users'), // API to fetch all users
        headers: {'Content-Type': 'application/json'}, // Setting the request headers
      );

      if (response.statusCode == 200) {
        // If the request is successful (status code 200), update the UI with the fetched users
        setState(() {
          users = jsonDecode(response.body); // Parse the response body to get the list of users
        });
      } else {
        // If the request fails, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load users')),
        );
      }
    } catch (e) {
      // Catch any errors that occur during the API request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to log out the user
  void _logout() async {
    await AuthService.logout(context); // Call the AuthService to log out the user
    // Navigate back to the login screen after logout
    Navigator.pushReplacementNamed(context, '/login'); // Adjust route name if needed
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
      // If the users list is empty, show a loading spinner (CircularProgressIndicator)
      // Otherwise, display the list of users
      body: users.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView.builder(
              itemCount: users.length, // Number of users to display
              itemBuilder: (context, index) {
                final user = users[index]; // Access individual user from the list
                return ListTile(
                  title: Text(user['username']), // Display the username of the user
                  onTap: () {
                    // When tapped, navigate to the chat screen with the selected user
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {
                        'currentUserId': widget.currentUserId, // Pass the current user's ID
                        'chatUserId': user['id'], // Pass the selected user's ID
                        'chatUserName': user['username'], // Pass the selected user's name
                      },
                    );
                  },
                );
              },
            ),
      // Floating action button to navigate to the sign-up screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the sign-up screen when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()), // Open sign-up screen
          );
        },
        child: const Icon(Icons.add), // "+" icon on the floating button
      ),
    );
  }
} 
  