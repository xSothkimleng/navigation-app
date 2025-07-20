import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/contact.dart';
import 'package:http/http.dart' as http;
import 'package:salesquake_app/services/auth_service.dart';

class ContactService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost';
  static String get _port => dotenv.env['API_PORT'] ?? '8080';
  static String get _apiUrl => '$_baseUrl:$_port/api/v1';

  static Future<ApiResponse<List<Contact>>> getContacts() async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Failed to load contacts');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };
    final response = await http.get(
      Uri.parse('$_apiUrl/contacts/detailed'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(responseData['data']);
      List<Contact> contacts =
          jsonList.map((jsonMap) => Contact.fromJson(jsonMap)).toList();
      return ApiResponse<List<Contact>>(
        data: contacts,
        message: responseData['message'] ?? 'Failed to load contacts',
      );
    }

    throw Exception('Failed to load contacts');
  }

  static Future<ApiResponse<Contact>> createContact(
      ContactInput contactInput) async {
    final token = await AuthService.getTokenFromStorage();
    if (token == null) {
      throw Exception('Authentication required');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Cookie': 'jwt=$token',
    };

    final response = await http.post(
      Uri.parse('$_apiUrl/contacts/detailed'),
      headers: headers,
      body: json.encode(contactInput.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);

      if (responseData['data'] != null) {
        final contact = Contact.fromJson(responseData['data']);

        return ApiResponse<Contact>(
          data: contact,
          message: responseData['message'] ?? 'Contact created successfully',
        );
      }
    }

    final responseData = json.decode(response.body);
    return ApiResponse<Contact>(
      data: null,
      message: responseData['message'] ?? 'Failed to create contact',
    );
  }
}
