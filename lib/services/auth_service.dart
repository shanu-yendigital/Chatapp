import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  //Store token in shared preferences
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

//Retrieve access token from shared preferences
Future<String?> getAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('accesstoken');
}

//Retrieve refresh token from SharedPreferences
Future<String?> getRefreshToken() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('refreshToken');
}

//Method to sign in and store tokens
Future<void> signIn(String username, String password, BuildContext context) async {
    var response = await http.post(
      Uri.parse('http://localhost:5008/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['accessToken'];
      final refreshToken = responseData['refreshToken'];

      // Save tokens to SharedPreferences
      await _saveTokens(accessToken, refreshToken);

      // Navigate to the home screen after successful login
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed! Please check your credentials.')),
      );
    }
  }

 // Method to refresh the access token
  Future<void> refreshAccessToken(BuildContext context) async {
    final refreshToken = await getRefreshToken();

    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('http://localhost:5008/api/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['accessToken'];

        // Save the new access token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', newAccessToken);
      } else {
        // Handle token refresh error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        logout(context);
      }
    } else {
      // Handle missing refresh token scenario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      logout(context);
    }
  }

  static Future<void> logout(BuildContext context) async {
    // Clear locally stored user data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // CallbackendAPI to logout
    var response = await http.post(
      Uri.parse('http://localhost:5008/api/auth/logout'), 
    );

    if (response.statusCode == 200) {
      // Navigate to the login screen after successful logout
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Handle logout error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed! Please try again.')),
      );
    }
  }
}

