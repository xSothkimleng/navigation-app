import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/contact.dart';
import 'package:salesquake_app/utils/http_client.dart';

class ContactService {
  static Future<ApiResponse<List<Contact>>> getContacts() async {
    return await HttpClient.fetchList(
      '/contacts/detailed',
      Contact.fromJson,
      errorMessage: 'Failed to load contacts',
    );
  }

  static Future<ApiResponse<Contact>> createContact(
      ContactInput contactInput) async {
    return await HttpClient.createObject(
      '/contacts/detailed',
      contactInput.toJson(),
      Contact.fromJson,
      successMessage: 'Contact created successfully',
      errorMessage: 'Failed to create contact',
    );
  }
}
