/// API 응답 모델
class AuthResponse {
  final bool success;
  final int status;
  final String message;
  final AuthData? data;
  final String timestamp;

  AuthResponse({
    required this.success,
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

/// 인증 데이터
class AuthData {
  final String accessToken;
  final String refreshToken;

  AuthData({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

