import 'auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class UserService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _apiUrl => '$_baseUrl:$_port/api';

  // Get user data from JWT token and fetch full profile from API
  static Future<User?> getCurrentUser() async {
    try {
      print('=== USER SERVICE: Getting current user ===');

      // Get the current user info from JWT token via AuthService
      final userInfo = await AuthService.getCurrentUser();
      print('User info from JWT: $userInfo');

      if (userInfo != null) {
        // Extract user ID and tenant ID from JWT
        final userId = userInfo['user_id'] as String?;
        final tenantId = userInfo['tenant_id'] as String?;

        print('Extracted - User ID: $userId, Tenant ID: $tenantId');

        if (userId != null) {
          // Fetch detailed user profile from API
          final userDetail = await getUserDetailFromUserId(userId);

          if (userDetail != null) {
            // Add tenant ID from JWT to the user detail if it's missing
            if (userDetail.tenantId == null && tenantId != null) {
              return userDetail.copyWith(tenantId: tenantId);
            }
            return userDetail;
          }
        } else {
          print('No user ID found in JWT token');
        }
      } else {
        print('No user info found in JWT token');
      }

      // Return null if no user info available
      return null;
    } catch (e) {
      print('=== ERROR in UserService.getCurrentUser(): $e ===');
      return null;
    }
  }

  // Fetch user details from API using user ID
  static Future<User?> getUserDetailFromUserId(String userId) async {
    try {
      print('=== API CALL START ===');
      print('Fetching user detail from API for user ID: $userId');

      // Get the JWT token to authenticate API request
      final token = await AuthService.getTokenFromStorage();
      if (token == null) {
        print('ERROR: No JWT token available for API request');
        return null;
      }

      print('Got JWT token for API request: ${token.substring(0, 50)}...');

      final headers = {
        'Content-Type': 'application/json',
        'Cookie': 'jwt=$token',
      };

      final apiUrl = '$_apiUrl/v1/users/$userId';
      print('Making API request to: $apiUrl');
      print('Request headers: $headers');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      print('=== API RESPONSE ===');
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Parsed response data: $responseData');

        // Based on your backend code, the response should have a 'data' field
        if (responseData['data'] != null) {
          final userData = responseData['data'];
          print('Extracted user data: $userData');

          // Create User object from API response (snake_case)
          return User.fromJson({
            'id': userData['id'] ?? userId,
            'first_name': userData['first_name'] ?? '',
            'last_name': userData['last_name'] ?? '',
            'email': userData['email'] ?? '',
            'profile_image':
                userData['profile_image'], // API might have this field
            'tenant_id': null, // Will be set by caller if needed
          });
        } else {
          print('ERROR: No data field in API response');
          return null;
        }
      } else {
        print('ERROR: API call failed with status ${response.statusCode}');
        print('Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('=== EXCEPTION in API call: $e ===');
      return null;
    }
  }

  static String getInitials(String firstName, [String? lastName]) {
    String initials = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials;
  }
}
