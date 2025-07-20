import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/opportunity.dart';
import 'package:http/http.dart' as http;
import 'package:salesquake_app/services/auth_service.dart';

class OpportunityService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _apiUrl => '$_baseUrl:$_port/api/v1';

  static Future<ApiResponse<List<Opportunity>>> getOpportunities() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Failed to load opportunities');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    final response = await http.get(
      Uri.parse('$_apiUrl/opportunities/detailed'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(responseData['data']);
      List<Opportunity> opportunities =
          jsonList.map((jsonMap) => Opportunity.fromJson(jsonMap)).toList();

      return ApiResponse<List<Opportunity>>(
        data: opportunities,
        message: responseData['message'] ?? 'Failed to load opportunities',
      );
    }

    throw Exception('Failed to load opportunities');
  }

  static Future<ApiResponse<Opportunity>> createOpportunity(
      OpportunityInput opportunityInput) async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    print(opportunityInput.toJson());
    final response = await http.post(
      Uri.parse('$_apiUrl/opportunities/detailed'),
      headers: headers,
      body: json.encode(opportunityInput.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);

      if (responseData['data'] != null) {
        final opportunity = Opportunity.fromJson(responseData['data']);
        return ApiResponse<Opportunity>(
          data: opportunity,
          message:
              responseData['message'] ?? 'Opportunity created successfully',
        );
      }
    }

    final responseData = json.decode(response.body);
    return ApiResponse<Opportunity>(
      data: null,
      message: responseData['message'] ?? 'Failed to create opportunity',
    );
  }

  static Future<ApiResponse<List<StageInfo>>> getStages() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Failed to load stages');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    final response = await http.get(
      Uri.parse('$_apiUrl/opportunities/stages'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(responseData['data']);
      List<StageInfo> stages =
          jsonList.map((jsonMap) => StageInfo.fromJson(jsonMap)).toList();

      return ApiResponse<List<StageInfo>>(
        data: stages,
        message: responseData['message'] ?? 'Failed to load stages',
      );
    }

    throw Exception('Failed to load stages');
  }
}
