import 'package:salesquake_app/models/api_response.dart';
import 'package:salesquake_app/models/opportunity.dart';
import 'package:salesquake_app/models/geometry.dart';
import 'package:salesquake_app/utils/http_client.dart';

class OpportunityService {
  static Future<ApiResponse<List<Opportunity>>> getOpportunities() async {
    return await HttpClient.fetchList(
      '/opportunities/detailed',
      Opportunity.fromJson,
      errorMessage: 'Failed to load opportunities',
    );
  }

  static Future<ApiResponse<Opportunity>> getOpportunityById(String id) async {
    return await HttpClient.fetchObject(
      '/opportunities/detailed/$id',
      Opportunity.fromJson,
      successMessage: 'Opportunity loaded successfully',
      errorMessage: 'Failed to load opportunity',
    );
  }

  static Future<ApiResponse<Opportunity>> createOpportunity(
      OpportunityInput opportunityInput) async {
    print(opportunityInput.toJson());
    return await HttpClient.createObject(
      '/opportunities/detailed',
      opportunityInput.toJson(),
      Opportunity.fromJson,
      successMessage: 'Opportunity created successfully',
      errorMessage: 'Failed to create opportunity',
    );
  }

  static Future<ApiResponse<List<StageInfo>>> getStages() async {
    return await HttpClient.fetchList(
      '/opportunities/stages',
      StageInfo.fromJson,
      errorMessage: 'Failed to load stages',
    );
  }

  static Future<ApiResponse<Opportunity>> updateOpportunityStage(
      String opportunityId, String stageId) async {
    try {
      // Get current opportunity to preserve all existing data
      final currentOpportunity = await getOpportunityById(opportunityId);
      if (currentOpportunity.data == null) {
        return ApiResponse<Opportunity>(
          data: null,
          message: currentOpportunity.message ??
              'Failed to get current opportunity data',
        );
      }

      // Create updated opportunity input with all current data + new stage_id
      final updatedOpportunityInput = OpportunityInput(
        name: currentOpportunity.data!.name,
        amount: currentOpportunity.data!.amount,
        contactId: currentOpportunity.data!.contact.id,
        companyId: currentOpportunity.data!.company.id,
        stageId: stageId, // This is the updated stage
        territoryId: currentOpportunity.data!.territory.id.isNotEmpty
            ? currentOpportunity.data!.territory.id
            : null,
        estimateCloseDate: currentOpportunity.data!.estimateCloseDate,
        actualCloseDate: currentOpportunity.data!.actualCloseDate,
        isActive: currentOpportunity.data!.isActive,
        locationOverride: currentOpportunity.data!.locationOverride != null
            ? GeoLocation.fromGeoPoint(
                currentOpportunity.data!.locationOverride!)
            : null,
      );

      return await HttpClient.updateObject(
        '/opportunities/detailed/$opportunityId',
        updatedOpportunityInput.toJson(),
        Opportunity.fromJson,
        successMessage: 'Stage updated successfully',
        errorMessage: 'Failed to update stage',
      );
    } catch (e) {
      return ApiResponse<Opportunity>(
        data: null,
        message: 'Failed to update stage: $e',
      );
    }
  }
}
