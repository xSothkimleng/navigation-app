import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('=== SPLASH SCREEN: Checking auth status ===');
    
    // Debug shared preferences
    await AuthService.debugSharedPreferences();
    
    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 2000));
    
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      print('Auth status result: $isLoggedIn');
      
      if (mounted) {
        if (isLoggedIn) {
          print('User is logged in, navigating to home screen');
          // User is already logged in, navigate to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          print('User is not logged in, navigating to login screen');
          // User is not logged in, navigate to login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // If there's an error, navigate to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            const SpinKitSpinningLines(
              color: Colors.blue,
              size: 80.0,
            ),
          ],
        ),
      ),
    );
  }
}
