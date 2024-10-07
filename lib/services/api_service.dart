import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter/material.dart';
class ApiService {
  final AuthService _authService = AuthService();

 // Method to make an authenticated API call  
  Future<http.Response> makeAuthenticatedRequest(String url,BuildContext context) async {
    String? accessToken = await _authService.getAccessToken();

   
    if (accessToken == null) {
      await _authService.refreshAccessToken(context);
      accessToken = await _authService.getAccessToken();
    }

    // Make the API request with the access token
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // If unauthorized, try to refresh the token and retry the request
    if (response.statusCode == 401) {
      await _authService.refreshAccessToken(context);
      accessToken = await _authService.getAccessToken();

      return http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    }

    return response;
  }
}