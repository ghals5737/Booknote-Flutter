import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth/auth_response.dart';

/// 인증 API 서비스
class AuthService {
  /// 환경변수에서 Base URL 가져오기
  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:9500';
  }

  /// 로그인 API 호출
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? '로그인에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }

  /// 구글 로그인 API 호출
  Future<AuthResponse> loginWithGoogle({
    required String email,
    required String name,
    required String googleId,
    String? profileImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'name': name,
          'googleId': googleId,
          if (profileImage != null) 'profileImage': profileImage,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorData['message'] ?? '구글 로그인에 실패했습니다.');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('네트워크 오류가 발생했습니다: $e');
    }
  }
}

