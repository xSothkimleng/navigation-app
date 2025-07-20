import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/opportunity.dart';
import 'package:http/http.dart' as http;
import 'package:salesquake_app/services/auth_service.dart';

class TerritoryService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _apiUrl => '$_baseUrl:$_port/api/v1';

  static Future<ApiResponse<List<TerritoryInfo>>> getTerritories() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Failed to load territories');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    final response = await http.get(
      Uri.parse('$_apiUrl/territories'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(responseData['data']);
      List<TerritoryInfo> territories =
          jsonList.map((jsonMap) => TerritoryInfo.fromJson(jsonMap)).toList();

      return ApiResponse<List<TerritoryInfo>>(
        data: territories,
        message: responseData['message'] ?? 'Failed to load territories',
      );
    }

    throw Exception('Failed to load territories');
  }
}
