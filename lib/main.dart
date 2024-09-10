import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case '/home':
            final String currentUserId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => HomeScreen(currentUserId: currentUserId),
            );
          case '/chat':
            final Map<String, String> args = settings.arguments as Map<String, String>;
            final String currentUserId = args['currentUserId']!;
            final String chatUserId = args['chatUserId']!;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: currentUserId,
                chatUserId: chatUserId,
              ),
            );
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpScreen());
          default:
            return MaterialPageRoute(builder: (context) => LoginScreen());
        }
      },
    );
  }
}
