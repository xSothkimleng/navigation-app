import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/country.dart';
import 'package:salesquake_app/utils/http_client.dart';

class CountryService {
  static Future<ApiResponse<List<Country>>> getCountries() async {
    return await HttpClient.fetchList(
      '/countries',
      Country.fromJson,
      successMessage: 'Countries loaded successfully',
      errorMessage: 'Failed to load countries',
    );
  }
}
