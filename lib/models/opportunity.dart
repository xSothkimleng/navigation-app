import 'package:salesquake_app/models/base_model.dart';
import 'package:salesquake_app/models/company.dart';
import 'package:salesquake_app/models/contact.dart';
import 'package:salesquake_app/models/geometry.dart';

class Opportunity extends IModel {
  final String name;
  final StageInfo stage;
  final Company company;
  final Contact contact;
  final TerritoryInfo territory;
  final double amount;
  final GeoPoint? locationOverride;
  final DateTime? estimatedCloseDate;
  final DateTime? actualCloseDate;

  Opportunity({
    required super.id,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.amount,
    required this.stage,
    required this.company,
    required this.contact,
    required this.territory,
    this.locationOverride,
    this.estimatedCloseDate,
    this.actualCloseDate,
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id']?.toString() ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      stage: StageInfo.fromJson(json['stage']),
      company: Company.fromJson(json['company']),
      contact: Contact.fromJson(json['contact']),
      territory: TerritoryInfo.fromJson(json['territory']),
      locationOverride: json['location_override'] != null
          ? (json['location_override'] is List
              ? (json['location_override'] as List)
                  .map((e) => (e as num).toDouble())
                  .toList()
              : json['location_override'] is Map
                  ? [
                      (json['location_override']['latitude'] as num?)
                              ?.toDouble() ??
                          0.0,
                      (json['location_override']['longitude'] as num?)
                              ?.toDouble() ??
                          0.0,
                    ]
                  : null)
          : null,
      estimatedCloseDate: json['estimated_close_date'] != null
          ? DateTime.tryParse(json['estimated_close_date'].toString())
          : null,
      actualCloseDate: json['actual_close_date'] != null
          ? DateTime.tryParse(json['actual_close_date'].toString())
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'name': name,
      'stage_id': stage.id,
      'company_override': company.id,
      'contact_override': contact.id,
      'amount_override': amount,
      'location_override': locationOverride,
      'estimated_close_date': estimatedCloseDate?.toIso8601String(),
      'actual_close_date': actualCloseDate?.toIso8601String(),
    };
  }
}

class StageInfo {
  final String id;
  final String name;
  final int percentage;
  final bool isActive;

  StageInfo({
    required this.id,
    required this.name,
    required this.percentage,
    required this.isActive,
  });

  factory StageInfo.fromJson(Map<String, dynamic> json) {
    return StageInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percentage': percentage,
      'isActive': isActive,
    };
  }
}

class TerritoryInfo {
  final String id;
  final String name;

  TerritoryInfo({
    required this.id,
    required this.name,
  });

  factory TerritoryInfo.fromJson(Map<String, dynamic> json) {
    return TerritoryInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class OpportunityInput {
  final String? id;
  final bool isActive;
  final String name;
  final double? amount;
  final String? stageId;
  final String? companyId;
  final String? contactId;
  final String? territoryId;
  final GeoLocation? locationOverride;
  final DateTime? estimatedCloseDate;
  final DateTime? actualCloseDate;
  final double? value;
  final String? description;

  OpportunityInput({
    this.id,
    required this.isActive,
    required this.name,
    this.amount,
    this.stageId,
    this.companyId,
    this.contactId,
    this.territoryId,
    this.locationOverride,
    this.estimatedCloseDate,
    this.actualCloseDate,
    this.value,
    this.description,
  });

  factory OpportunityInput.fromJson(Map<String, dynamic> json) {
    return OpportunityInput(
      id: json['id']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      name: json['name']?.toString() ?? '',
      stageId: json['stage_id']?.toString(),
      companyId: json['company_id']?.toString(),
      contactId: json['contact_id']?.toString(),
      amount: json['amount_override']?.toDouble(),
      territoryId: json['territory_id']?.toString(),
      locationOverride: json['location_override'] != null
          ? GeoLocation.fromGeoPoint(
              List<double>.from(json['location_override']))
          : null,
      estimatedCloseDate: json['estimated_close_date'] != null
          ? DateTime.tryParse(json['estimated_close_date'].toString())
          : null,
      actualCloseDate: json['actual_close_date'] != null
          ? DateTime.tryParse(json['actual_close_date'].toString())
          : null,
      value: json['value']?.toDouble(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'name': name,
      'is_active': isActive,
    };

    if (id != null) data['id'] = id;
    if (stageId != null) data['stage_id'] = stageId;
    if (amount != null) data['amount_override'] = amount;
    if (companyId != null) data['company_override'] = companyId;
    if (contactId != null) data['contact_override'] = contactId;
    if (territoryId != null) data['territory_id'] = territoryId;
    if (locationOverride != null) {
      data['location_override'] = locationOverride!.toJson();
    }
    if (estimatedCloseDate != null) {
      // Ensure the date is in UTC and has proper timezone info
      String dateStr = estimatedCloseDate!.toUtc().toIso8601String();
      if (!dateStr.endsWith('Z')) {
        dateStr = dateStr + 'Z';
      }
      data['estimated_close_date'] = dateStr;
    }
    if (actualCloseDate != null) {
      // Ensure the date is in UTC and has proper timezone info
      String dateStr = actualCloseDate!.toUtc().toIso8601String();
      if (!dateStr.endsWith('Z')) {
        dateStr = dateStr + 'Z';
      }
      data['actual_close_date'] = dateStr;
    }

    return data;
  }
}
