import 'package:flutter/material.dart';
import 'package:navigation_app/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Map App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
