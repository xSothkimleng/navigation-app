import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class AuthService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _authUrl => '$_baseUrl:$_port/auth';

  static String? _jwtToken;
  static Map<String, dynamic>? _userInfo;

  static Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$_authUrl/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      print('Login response headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Backend returns plain text "login successful" for success
        print('Login successful - Response: ${response.body}');

        // Handle cookies from response if present
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          print('Received cookies: $cookies');

          // Extract JWT token from cookies
          final jwtCookie = _extractJwtFromCookies(cookies);
          if (jwtCookie != null) {
            _jwtToken = jwtCookie;
            await _saveTokenToStorage(jwtCookie);

            // Decode JWT to extract user info
            final userInfo = _decodeJWT(jwtCookie);
            if (userInfo != null) {
              _userInfo = userInfo;
              print('=== DECODED USER INFO FROM JWT ===');
              print('Tenant ID: ${userInfo['tenant_id']}');
              print('User ID: ${userInfo['user_id']}');
              print('Expiration: ${userInfo['exp']}');
              print('Issued At: ${userInfo['iat']}');
              print('=================================');
            }
          }
        }

        return ApiResponse<LoginResponse>(
          data: LoginResponse(
            token: _jwtToken ?? '',
            user: _userInfo,
          ),
          message: response.body, // "login successful"
        );
      } else {
        // Parse error response in format { "message": string, "error": string }
        try {
          final responseData = jsonDecode(response.body);
          return ApiResponse<LoginResponse>(
            error: responseData['message'] ??
                responseData['error'] ??
                'Login failed',
          );
        } catch (e) {
          // If JSON parsing fails, use the raw response
          return ApiResponse<LoginResponse>(
            error: response.body.isNotEmpty ? response.body : 'Login failed',
          );
        }
      }
    } catch (e) {
      print('Login error: $e');
      return ApiResponse<LoginResponse>(
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  static String? _extractJwtFromCookies(String cookies) {
    // Parse cookies to extract JWT token
    final cookieParts = cookies.split(';');
    for (final part in cookieParts) {
      final trimmed = part.trim();
      if (trimmed.startsWith('jwt=')) {
        return trimmed.substring(4); // Remove 'jwt=' prefix
      }
    }
    return null;
  }

  static Map<String, dynamic>? _decodeJWT(String token) {
    try {
      print('Attempting to decode JWT token...');
      // For demonstration, we'll decode without verification
      // In production, you should verify the token with the secret
      final jwt = JWT.decode(token);
      final payload = jwt.payload;

      print('JWT Payload: $payload');

      if (payload is Map<String, dynamic>) {
        return {
          'tenant_id': payload['tenant_id'],
          'user_id': payload['user_id'],
          'exp': payload['exp'],
          'iat': payload['iat'],
        };
      } else {
        print('JWT payload is not a Map<String, dynamic>');
        return null;
      }
    } catch (e) {
      print('JWT decode error: $e');
      return null;
    }
  }

  static Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<void> saveKeepMeLoggedIn(bool keepLoggedIn) async {
    print('Saving keep me logged in preference: $keepLoggedIn');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_me_logged_in', keepLoggedIn);
    print('Keep me logged in preference saved');
  }

  static Future<bool> getKeepMeLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool('keep_me_logged_in') ?? false;
    print('Retrieved keep me logged in preference: $result');
    return result;
  }

  static Future<String?> getTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print(
        'Retrieved token from storage: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
    return token;
  }

  static Future<bool> isLoggedIn() async {
    print('=== CHECKING LOGIN STATUS ===');
    final keepMeLoggedIn = await getKeepMeLoggedIn();
    print('Keep me logged in preference: $keepMeLoggedIn');

    if (!keepMeLoggedIn) {
      print('Keep me logged in is false, user not logged in');
      return false;
    }

    final token = await getTokenFromStorage();
    print('Token from storage: ${token?.substring(0, 20)}...');

    if (token == null) {
      print('No token found in storage');
      return false;
    }

    // Check if token is valid
    final userInfo = _decodeJWT(token);
    print('Decoded user info: $userInfo');

    if (userInfo != null) {
      final exp = userInfo['exp'];

      // If token has expiration, check if it's expired
      if (exp != null) {
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        final now = DateTime.now();
        print('Token expires at: $expirationTime');
        print('Current time: $now');
        print('Token expired: ${now.isAfter(expirationTime)}');

        if (now.isAfter(expirationTime)) {
          // Token expired, clear it
          print('Token expired, clearing tokens');
          await clearTokens();
          return false;
        }
      } else {
        // Token doesn't have expiration, assume it's valid
        print('Token does not have expiration field, assuming valid');
      }

      // Set current token and user info for app use
      _jwtToken = token;
      _userInfo = userInfo;
      print('User is logged in, token is valid');
      return true;
    }

    print('Failed to decode token');
    return false;
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getTokenFromStorage();
    if (token != null) {
      return _decodeJWT(token);
    }
    return null;
  }

  static Future<ApiResponse<String>> logout() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final token = await getTokenFromStorage();
      if (token != null) {
        headers['Cookie'] = 'jwt=$token';
      }

      final response = await http.delete(
        Uri.parse('$_authUrl/logout'),
        headers: headers,
      );

      print('Logout response status: ${response.statusCode}');
      print('Logout response body: ${response.body}');

      // Backend returns 404 for successful logout (unusual but that's how it's implemented)
      // We accept both 200 and 404 as success, or handle logout locally if backend fails
      if (response.statusCode == 200 || response.statusCode == 404) {
        // Clear stored tokens and user info
        await clearTokens();

        return ApiResponse<String>(
          data: 'Logout successful',
          message: 'Logged out successfully',
        );
      } else {
        // Even if backend logout fails, we can still clear local tokens
        // since JWT tokens are stateless
        print('Backend logout failed, clearing local tokens anyway');
        await clearTokens();

        return ApiResponse<String>(
          data: 'Logout successful',
          message: 'Logged out successfully (local)',
        );
      }
    } catch (e) {
      print('Network error during logout: $e');
      // Even if network fails, we can still clear local tokens
      // since JWT tokens are stateless
      await clearTokens();

      return ApiResponse<String>(
        data: 'Logout successful',
        message: 'Logged out successfully (offline)',
      );
    }
  }

  // Alternative logout method that doesn't require backend call
  // Since JWT tokens are stateless, clearing local storage is sufficient
  static Future<ApiResponse<String>> logoutLocal() async {
    try {
      print('Performing local logout...');
      await clearTokens();

      return ApiResponse<String>(
        data: 'Logout successful',
        message: 'Logged out successfully',
      );
    } catch (e) {
      print('Error during local logout: $e');
      return ApiResponse<String>(
        error: 'Error during logout: ${e.toString()}',
      );
    }
  }

  static Future<void> clearTokens() async {
    print('Clearing all tokens and preferences');
    _jwtToken = null;
    _userInfo = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('keep_me_logged_in');
    print('All tokens and preferences cleared');
  }

  // Debug method to check all stored values
  static Future<void> debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print('=== SHARED PREFERENCES DEBUG ===');
    for (final key in keys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    print('================================');
  }
}
