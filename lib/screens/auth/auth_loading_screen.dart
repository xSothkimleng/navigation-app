// Screen that handles authentication/loading logic and shows splash widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../widgets/common/splash_widget.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class AuthLoadingScreen extends StatefulWidget {
  const AuthLoadingScreen({Key? key}) : super(key: key);

  @override
  State<AuthLoadingScreen> createState() => _AuthLoadingScreenState();
}

class _AuthLoadingScreenState extends State<AuthLoadingScreen> {
  String _currentMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _performAppInitialization();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> _performAppInitialization() async {
    try {
      // Step 1: Check backend server connectivity
      setState(() {
        _currentMessage = "Checking server connection...";
      });

      final bool isServerResponsive = await _checkServerHealth();
      if (!isServerResponsive) {
        setState(() {
          _currentMessage = "Server is not responding. Please try again later.";
        });
        // Don't proceed further if server is not responsive
        return;
      }

      // Step 2: Initialize services
      setState(() {
        _currentMessage = "Initializing services...";
      });
      await Future.delayed(const Duration(seconds: 1));

      // Step 3: Debug shared preferences
      print('=== AUTH LOADING SCREEN: Debugging shared preferences ===');
      await AuthService.debugSharedPreferences();

      // Step 4: Check user authentication
      setState(() {
        _currentMessage = "Checking authentication...";
      });
      await Future.delayed(const Duration(seconds: 1));

      final bool isUserLoggedIn = await _checkUserAuthentication();

      // Step 5: Navigate based on auth status
      if (isUserLoggedIn) {
        setState(() {
          _currentMessage = "Loading dashboard...";
        });
        await Future.delayed(const Duration(seconds: 1));
        _navigateToHome();
      } else {
        setState(() {
          _currentMessage = "Redirecting to login...";
        });
        await Future.delayed(const Duration(seconds: 1));
        _navigateToLogin();
      }
    } catch (e) {
      print('Error during app initialization: $e');
      setState(() {
        _currentMessage = "Error: ${e.toString()}";
      });
      // Handle error - navigate to login as fallback
      await Future.delayed(const Duration(seconds: 2));
      _navigateToLogin();
    }
  }

  Future<bool> _checkServerHealth() async {
    try {
      print('=== CHECKING SERVER HEALTH ===');

      // Get API base URL and port from environment
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost';
      final port = dotenv.env['API_PORT'] ?? '8080';
      final healthCheckUrl = '$baseUrl:$port';

      print('Testing server at: $healthCheckUrl');

      // Make a simple GET request to the base URL
      final response = await http.get(
        Uri.parse(healthCheckUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Server response status: ${response.statusCode}');
      print('Server response body: ${response.body}');

      // Consider server responsive if we get ANY response (even 404, 500, etc.)
      // This means the server is running and can handle requests
      if (response.statusCode >= 200 && response.statusCode < 600) {
        print('✅ Server is responsive');
        return true;
      } else {
        print('❌ Server returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Server health check failed: $e');
      return false;
    }
  }

  Future<bool> _checkUserAuthentication() async {
    try {
      // Check if user is logged in using AuthService
      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // Get current user info and log it
        final userInfo = await AuthService.getCurrentUser();
        if (userInfo != null) {
          print('=== USER INFO FROM JWT ===');
          print('Tenant ID: ${userInfo['tenant_id']}');
          print('User ID: ${userInfo['user_id']}');
          print('Expiration: ${userInfo['exp']}');
          print('Issued At: ${userInfo['iat']}');
          print('========================');
        }

        // User is logged in and has valid token
        print('User is authenticated and has valid session');
        return true;
      } else {
        // User is not logged in or token is invalid/expired
        print('User is not authenticated or session has expired');
        return false;
      }
    } catch (e) {
      print('Error checking authentication: $e');
      // On error, assume user is not authenticated
      return false;
    }
  }

  void _navigateToHome() {
    print('=== AUTH LOADING SCREEN: Navigating to Home Screen ===');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _navigateToLogin() {
    print('=== AUTH LOADING SCREEN: Navigating to Login Screen ===');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashWidget(
        message: _currentMessage,
        showSpinner: true,
      ),
    );
  }
}
