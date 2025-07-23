import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app storage using SharedPreferences
class StorageService {
  static const String _apiUrlKey = 'api_url';
  static const String _apiPortKey = 'api_port';

  /// Save API URL to storage
  static Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
    print('API URL saved to storage: $url');
  }

  /// Save API port to storage
  static Future<void> saveApiPort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiPortKey, port);
    print('API port saved to storage: $port');
  }

  /// Get API URL from storage
  static Future<String?> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_apiUrlKey);
    print('Retrieved API URL from storage: $url');
    return url;
  }

  /// Get API port from storage
  static Future<String?> getApiPort() async {
    final prefs = await SharedPreferences.getInstance();
    final port = prefs.getString(_apiPortKey);
    print('Retrieved API port from storage: $port');
    return port;
  }

  /// Check if API configuration exists
  static Future<bool> hasApiConfiguration() async {
    final url = await getApiUrl();
    return url != null && url.isNotEmpty;
  }

  /// Clear API configuration
  static Future<void> clearApiConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiUrlKey);
    await prefs.remove(_apiPortKey);
    print('API configuration cleared');
  }

  /// Get full API base URL (URL + port)
  static Future<String?> getFullApiUrl() async {
    final url = await getApiUrl();
    final port = await getApiPort();

    if (url == null || url.isEmpty) {
      return null;
    }

    if (port != null && port.isNotEmpty) {
      return '$url:$port';
    }

    return url;
  }

  /// Debug method to check all stored values
  static Future<void> debugStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    print('=== STORAGE SERVICE DEBUG ===');
    for (final key in keys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    print('============================');
  }
}
