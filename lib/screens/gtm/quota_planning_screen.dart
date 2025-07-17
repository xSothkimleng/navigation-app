import 'package:flutter/material.dart';

class QuotaPlanningScreen extends StatelessWidget {
  const QuotaPlanningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Quota Planning',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
