
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/review/review_models.dart';
import '../utils/token_storage.dart';

class ReviewService {
  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:9500';
  }

  Future<String?> _getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  /// 오늘의 복습 항목 조회 API
  Future<TodayReviewData> getTodayReviews() async {
    final url = Uri.parse('$baseUrl/api/v1/reviews/today');
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
        final reviewResponse = TodayReviewResponse.fromJson(jsonMap);

        if (reviewResponse.success) {
          return reviewResponse.data;
        } else {
          throw Exception(reviewResponse.message);
        }
      } else {
        throw Exception('Failed to load today\'s reviews');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  /// 복습 항목 완료 처리 API
  Future<void> completeReviewItem(
    int reviewId,
    int reviewItemId,
    String responseType,
  ) async {
    final url = Uri.parse('$baseUrl/api/v1/reviews/$reviewId/items/$reviewItemId/complete');
    final token = await _getAccessToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'response': responseType}),
      );

      if (response.statusCode != 200) {
        // API가 실패한 경우 예외 발생
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to complete review item.');
      }
      // 성공 시 별도의 반환 값 없음
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  /// 복습 기록 조회 API
  Future<ReviewHistoryPageData> getReviewHistory({
    int page = 0,
    int size = 100,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    final url = Uri.parse('$baseUrl/api/v1/reviews/history')
        .replace(queryParameters: queryParams);
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
        final historyResponse = ReviewHistoryResponse.fromJson(jsonMap);

        if (historyResponse.success) {
          return historyResponse.data;
        } else {
          throw Exception(historyResponse.message);
        }
      } else {
        throw Exception('Failed to load review history');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }
}
