import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/country.dart';
import 'package:http/http.dart' as http;
import 'package:salesquake_app/services/auth_service.dart';

class CountryService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _apiUrl => '$_baseUrl:$_port/api/v1';

  static Future<ApiResponse<List<Country>>> getCountries() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Failed to load companies');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    final response = await http.get(
      Uri.parse('$_apiUrl/countries'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(responseData['data']);
      List<Country> countries =
          jsonList.map((jsonMap) => Country.fromJson(jsonMap)).toList();

      return ApiResponse<List<Country>>(
        data: countries,
        message: responseData['message'] ?? 'Countries loaded successfully',
      );
    }

    throw Exception('Failed to load countries');
  }
}
