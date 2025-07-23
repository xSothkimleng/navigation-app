import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/opportunity.dart';
import 'package:salesquake_app/utils/http_client.dart';

class TerritoryService {
  static Future<ApiResponse<List<TerritoryInfo>>> getTerritories() async {
    return await HttpClient.fetchList(
      '/territories',
      TerritoryInfo.fromJson,
      errorMessage: 'Failed to load territories',
    );
  }
}
