import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/statistics/statistics_response.dart';
import '../utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatisticsService {
  /// 환경변수에서 Base URL 가져오기
  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:9500';
  }

  Future<String?> _getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  /// 내 독서 통계 조회
  Future<StatisticsData> getMyStatistics() async {
    final url = Uri.parse('$baseUrl/api/v1/stats/me');
    final token = await _getAccessToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        
        final statisticsResponse = StatisticsResponse.fromJson(jsonMap);
        
        if (statisticsResponse.success) {
          return statisticsResponse.data;
        } else {
          throw Exception(statisticsResponse.message);
        }
      } else {
        throw Exception('Failed to load statistics');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }
}

