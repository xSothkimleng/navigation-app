class ApiResponse<T> {
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'],
      message: json['message'],
      error: json['error'],
    );
  }
}

class LoginResponse {
  final String token;
  final String? refreshToken;
  final Map<String, dynamic>? user;

  LoginResponse({
    required this.token,
    this.refreshToken,
    this.user,
  });
}
