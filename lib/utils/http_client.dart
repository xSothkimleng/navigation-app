import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/api_response.dart';

/// A utility class for making authenticated HTTP requests
/// This class automatically handles authentication headers for all API calls
class HttpClient {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _fallbackApiUrl => '$_baseUrl:$_port/api/v1';

  /// Get API URL from storage or fallback to environment variables
  static Future<String> _getApiUrl() async {
    final storedUrl = await StorageService.getFullApiUrl();
    if (storedUrl != null) {
      return '$storedUrl/api/v1';
    }
    return _fallbackApiUrl;
  }

  /// Get common headers with authentication
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Authentication required');
    }

    return {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
  }

  /// Make an authenticated GET request
  static Future<http.Response> get(String endpoint) async {
    final headers = await _getAuthHeaders();
    final apiUrl = await _getApiUrl();
    return await http.get(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
    );
  }

  /// Make an authenticated POST request
  static Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _getAuthHeaders();
    final apiUrl = await _getApiUrl();
    return await http.post(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  /// Make an authenticated PUT request
  static Future<http.Response> put(String endpoint, {Object? body}) async {
    final headers = await _getAuthHeaders();
    final apiUrl = await _getApiUrl();
    return await http.put(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  /// Make an authenticated PATCH request
  static Future<http.Response> patch(String endpoint, {Object? body}) async {
    final headers = await _getAuthHeaders();
    final apiUrl = await _getApiUrl();
    return await http.patch(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
  }

  /// Make an authenticated DELETE request
  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getAuthHeaders();
    final apiUrl = await _getApiUrl();
    return await http.delete(
      Uri.parse('$apiUrl$endpoint'),
      headers: headers,
    );
  }

  /// Convenience method to fetch and parse a single object
  static Future<ApiResponse<T>> fetchObject<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      final response = await get(endpoint);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final object = fromJson(responseData['data']);
          return ApiResponse<T>(
            data: object,
            message: responseData['message'] ?? successMessage ?? 'Success',
          );
        }
      }

      final responseData = json.decode(response.body);
      return ApiResponse<T>(
        data: null,
        message:
            responseData['message'] ?? errorMessage ?? 'Failed to fetch data',
      );
    } catch (e) {
      return ApiResponse<T>(
        data: null,
        message: errorMessage ?? 'Error: $e',
      );
    }
  }

  /// Convenience method to fetch and parse a list of objects
  static Future<ApiResponse<List<T>>> fetchList<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      final response = await get(endpoint);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          List<Map<String, dynamic>> jsonList =
              List<Map<String, dynamic>>.from(responseData['data']);
          List<T> objects =
              jsonList.map((jsonMap) => fromJson(jsonMap)).toList();

          return ApiResponse<List<T>>(
            data: objects,
            message: responseData['message'] ?? successMessage ?? 'Success',
          );
        }
      }

      throw Exception(errorMessage ?? 'Failed to fetch list');
    } catch (e) {
      throw Exception('${errorMessage ?? "Error"}: $e');
    }
  }

  /// Convenience method to create an object
  static Future<ApiResponse<T>> createObject<T>(
    String endpoint,
    Object body,
    T Function(Map<String, dynamic>) fromJson, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      final response = await post(endpoint, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final object = fromJson(responseData['data']);
          return ApiResponse<T>(
            data: object,
            message: responseData['message'] ??
                successMessage ??
                'Created successfully',
          );
        }
      }

      final responseData = json.decode(response.body);
      return ApiResponse<T>(
        data: null,
        message: responseData['message'] ?? errorMessage ?? 'Failed to create',
      );
    } catch (e) {
      return ApiResponse<T>(
        data: null,
        message: '${errorMessage ?? "Failed to create"}: $e',
      );
    }
  }

  /// Convenience method to update an object
  static Future<ApiResponse<T>> updateObject<T>(
    String endpoint,
    Object body,
    T Function(Map<String, dynamic>) fromJson, {
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      final response = await patch(endpoint, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final object = fromJson(responseData['data']);
          return ApiResponse<T>(
            data: object,
            message: responseData['message'] ??
                successMessage ??
                'Updated successfully',
          );
        }
      }

      final responseData = json.decode(response.body);
      return ApiResponse<T>(
        data: null,
        message: responseData['message'] ?? errorMessage ?? 'Failed to update',
      );
    } catch (e) {
      return ApiResponse<T>(
        data: null,
        message: '${errorMessage ?? "Failed to update"}: $e',
      );
    }
  }

  /// Parse response and handle common error scenarios
  static T parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        return fromJson(responseData['data']);
      }
    }
    throw Exception('Failed to parse response: ${response.statusCode}');
  }

  /// Parse response for list data
  static List<T> parseListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        List<Map<String, dynamic>> jsonList =
            List<Map<String, dynamic>>.from(responseData['data']);
        return jsonList.map((jsonMap) => fromJson(jsonMap)).toList();
      }
    }
    throw Exception('Failed to parse list response: ${response.statusCode}');
  }

  /// Get the message from response body
  static String? getResponseMessage(http.Response response) {
    try {
      final responseData = json.decode(response.body);
      return responseData['message'];
    } catch (e) {
      return null;
    }
  }
}
