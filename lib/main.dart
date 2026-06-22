import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AOIApp());
}

class AOIApp extends StatelessWidget {
  const AOIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-AOI Client',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
