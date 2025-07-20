import 'package:salesquake_app/models/base_model.dart';
import 'company.dart';
import 'country.dart';

class Contact extends IModel {
  final Company? company;
  final CountryInfo? country;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;

  Contact({
    required super.id,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    this.company,
    this.country,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id']?.toString() ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      company: json['company'] != null
          ? Company.fromJson(json['company'])
          : (json['company_id'] != null
              ? Company(
                  id: json['company_id']?.toString() ?? '',
                  isActive: true,
                  createdAt: '',
                  updatedAt: '',
                  name: '',
                )
              : null),
      country: json['country'] != null
          ? CountryInfo.fromJson(json['country'])
          : (json['country_id'] != null
              ? CountryInfo(
                  id: (json['country_id'] as num?)?.toInt(),
                  name: null,
                  iso: null,
                  phonecode: null,
                )
              : null),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'company': company?.toJson(),
      'companyId': company?.id,
      'country': country?.toJson(),
      'countryId': country?.id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
    };
  }
}

class ContactInput {
  final String? id;
  final bool isActive;
  final int? companyId;
  final int? countryId;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;

  ContactInput({
    this.id,
    required this.isActive,
    this.companyId,
    this.countryId,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.email,
  });

  factory ContactInput.fromJson(Map<String, dynamic> json) {
    return ContactInput(
      id: json['id']?.toString(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      companyId: json['company_id']?.toInt() ?? json['companyId']?.toInt(),
      countryId: json['country_id']?.toInt() ?? json['countryId']?.toInt(),
      firstName:
          json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName:
          json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'is_active': isActive,
      if (companyId != null) 'company_id': companyId,
      if (countryId != null) 'country_id': countryId,
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    };
  }
}
