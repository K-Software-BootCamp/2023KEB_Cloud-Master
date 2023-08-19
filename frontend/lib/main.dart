import 'package:flutter/material.dart';
import 'package:test_project/page/login.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "reviewApp",
      theme: ThemeData(
        //primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LogIn(),
    );
  }
}
