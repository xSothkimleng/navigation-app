import 'base_model.dart';
import 'country.dart';
import 'geometry.dart';

class Company extends IModel {
  final CountryInfo? country;
  final String name;
  final String? address;
  final GeoPoint? location;
  final String? phone;
  final String? postalCode;
  final String? website;

  Company({
    required super.id,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    this.country,
    required this.name,
    this.address,
    this.location,
    this.phone,
    this.postalCode,
    this.website,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      updatedAt:
          json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '',
      country: json['country'] != null
          ? CountryInfo.fromJson(json['country'])
          : (json['country_id'] != null
              ? CountryInfo(
                  id: (json['country_id'] as num?)?.toInt() ??
                      (json['countryId'] as num?)?.toInt(),
                  name: null,
                  iso: null,
                  phonecode: null,
                )
              : null),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      location: json['location'] != null
          ? List<double>.from(
              json['location'].map((x) => (x as num).toDouble()))
          : null,
      phone: json['phone']?.toString(),
      postalCode:
          json['postal_code']?.toString() ?? json['postalCode']?.toString(),
      website: json['website']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'country': country?.toJson(),
      'name': name,
      'address': address,
      'location':
          location, // GeoPoint is already a List<double>, no conversion needed
      'phone': phone,
      'postal_code': postalCode,
      'website': website,
    };
  }
}

class CompanyInput extends IModelInput {
  final int? countryId;
  final String name;
  final String? address;
  final GeoLocation? location;
  final String? phone;
  final String? postalCode;
  final String? website;

  CompanyInput({
    super.id,
    required super.isActive,
    this.countryId,
    required this.name,
    this.address,
    this.location,
    this.phone,
    this.postalCode,
    this.website,
  });

  factory CompanyInput.fromJson(Map<String, dynamic> json) {
    return CompanyInput(
      id: json['id']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      countryId: (json['country_id'] as num?)?.toInt() ??
          (json['countryId'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      location: json['location'] != null
          ? GeoLocation.fromJson(json['location'])
          : null,
      phone: json['phone']?.toString(),
      postalCode:
          json['postal_code']?.toString() ?? json['postalCode']?.toString(),
      website: json['website']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'country_id': countryId,
      'name': name,
      'address': address,
      'location': location?.toJson(),
      'phone': phone,
      'postal_code': postalCode,
      'website': website,
    };
  }
}
