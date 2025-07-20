import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:http/http.dart' as http;
import 'package:salesquake_app/services/auth_service.dart';

class CompanyService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _apiUrl => '$_baseUrl:$_port/api/v1';

  static Future<ApiResponse<List<Company>>> getCompanies() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Failed to load companies');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    final response = await http.get(
      Uri.parse('$_apiUrl/companies/detailed'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(responseData['data']);
      List<Company> companies =
          jsonList.map((jsonMap) => Company.fromJson(jsonMap)).toList();

      return ApiResponse<List<Company>>(
        data: companies,
        message: responseData['message'] ?? 'Failed to load companies',
      );
    }

    throw Exception('Failed to load companies');
  }

  static Future<ApiResponse<Company>> createCompany(
      CompanyInput companyInput) async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };

    final response = await http.post(
      Uri.parse('$_apiUrl/companies'),
      headers: headers,
      body: json.encode(companyInput.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);

      if (responseData['data'] != null) {
        final company = Company.fromJson(responseData['data']);
        return ApiResponse<Company>(
          data: company,
          message: responseData['message'] ?? 'Company created successfully',
        );
      }
    }

    final responseData = json.decode(response.body);
    return ApiResponse<Company>(
      data: null,
      message: responseData['message'] ?? 'Failed to create company',
    );
  }
}
