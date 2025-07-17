import 'package:flutter/material.dart';
import 'main_app_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the main app layout with sidebar navigation
    return const MainAppLayout();
  }
}
