import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:salesquake_app/utils/http_client.dart';

class CompanyService {
  static Future<ApiResponse<List<Company>>> getCompanies() async {
    return await HttpClient.fetchList(
      '/companies/detailed',
      Company.fromJson,
      errorMessage: 'Failed to load companies',
    );
  }

  static Future<ApiResponse<Company>> createCompany(
      CompanyInput companyInput) async {
    return await HttpClient.createObject(
      '/companies',
      companyInput.toJson(),
      Company.fromJson,
      successMessage: 'Company created successfully',
      errorMessage: 'Failed to create company',
    );
  }
}
