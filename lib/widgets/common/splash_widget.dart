// Reusable splash widget that can be used anywhere
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashWidget extends StatelessWidget {
  final String? message;
  final bool showSpinner;
  final Color? backgroundColor;

  const SplashWidget({
    Key? key,
    this.message,
    this.showSpinner = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image - replace with your actual logo
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/logo.png', // Your logo file
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return const Icon(
                    Icons.navigation,
                    size: 100,
                    color: Colors.blue,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SalesQuake',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            if (showSpinner) ...[
              const SpinKitSpinningLines(
                color: Colors.blue,
                size: 80.0,
              ),
              if (message != null) ...[
                const SizedBox(height: 20),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
