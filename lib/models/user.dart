// User data model
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImage;
  final String? tenantId;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profileImage,
    this.tenantId,
  });

  String get fullName => '$firstName $lastName'.trim();

  // Get user initials for avatar display
  String get initials {
    String result = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    if (lastName.isNotEmpty) {
      result += lastName[0].toUpperCase();
    }
    return result;
  }

  // Check if user has a profile image
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  // Validate email format
  bool get hasValidEmail => email.contains('@') && email.contains('.');

  // Check if user data is complete
  bool get isComplete =>
      id.isNotEmpty &&
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      hasValidEmail;

  // Convert from JSON - handles both camelCase and snake_case from API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      // Handle both camelCase (frontend) and snake_case (API) formats
      firstName:
          json['firstName']?.toString() ?? json['first_name']?.toString() ?? '',
      lastName:
          json['lastName']?.toString() ?? json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileImage:
          json['profileImage']?.toString() ?? json['profile_image']?.toString(),
      tenantId: json['tenantId']?.toString() ?? json['tenant_id']?.toString(),
    );
  }

  // Convert to JSON for API (snake_case format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_image': profileImage,
      'tenant_id': tenantId,
    };
  }

  // Convert to JSON for frontend (camelCase format)
  Map<String, dynamic> toJsonCamelCase() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImage': profileImage,
      'tenantId': tenantId,
    };
  }

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? profileImage,
    String? tenantId,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.profileImage == profileImage &&
        other.tenantId == tenantId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      firstName,
      lastName,
      email,
      profileImage,
      tenantId,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, email: $email, profileImage: $profileImage, tenantId: $tenantId)';
  }
}
