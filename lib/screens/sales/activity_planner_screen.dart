import 'package:flutter/material.dart';

class ActivityPlannerScreen extends StatelessWidget {
  const ActivityPlannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Activity Planner',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
