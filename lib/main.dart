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
            final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
            final String currentUserId = args['currentUserId'].toString();
            final String chatUserId = args['chatUserId'].toString();
             final String targetUserId = args['targetUserId'].toString();
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                targetUserId: targetUserId,
                 currentUserId: currentUserId,
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
