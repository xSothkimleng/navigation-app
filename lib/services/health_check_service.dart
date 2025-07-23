import 'package:http/http.dart' as http;
import 'dart:async';

/// Service for checking API server health and connectivity
class HealthCheckService {
  /// Check if the server is responsive at the given URL
  static Future<bool> checkServerHealth(String baseUrl) async {
    try {
      print('=== HEALTH CHECK SERVICE ===');
      print('Testing server at: $baseUrl');

      // Make a simple GET request to the base URL with timeout
      final response = await http.get(
        Uri.parse(baseUrl),
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

  /// Test connectivity to a specific endpoint
  static Future<bool> testEndpoint(String fullUrl, String endpoint) async {
    try {
      print('Testing endpoint: $fullUrl$endpoint');

      final response = await http.get(
        Uri.parse('$fullUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      print('Endpoint response status: ${response.statusCode}');

      // Consider endpoint accessible if we get any response
      return response.statusCode >= 200 && response.statusCode < 600;
    } catch (e) {
      print('❌ Endpoint test failed: $e');
      return false;
    }
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Test multiple endpoints to verify API availability
  static Future<bool> testApiAvailability(String baseUrl) async {
    try {
      // Test basic connectivity first
      final basicConnectivity = await checkServerHealth(baseUrl);
      if (!basicConnectivity) {
        return false;
      }

      // Test common API endpoints that should exist
      final endpoints = ['/api/v1', '/health', '/ping'];

      for (final endpoint in endpoints) {
        final isAccessible = await testEndpoint(baseUrl, endpoint);
        if (isAccessible) {
          print('✅ Found accessible endpoint: $endpoint');
          return true;
        }
      }

      // If no specific endpoints work, but basic connectivity works,
      // consider it available
      print('✅ Basic connectivity confirmed, API likely available');
      return true;
    } catch (e) {
      print('❌ API availability test failed: $e');
      return false;
    }
  }
}
