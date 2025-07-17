// App constants and configuration
import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'SalesQuake Mobile';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://your-api.com/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // UI Constants
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 4.0;
  
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
  );
  
  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  
  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
}
