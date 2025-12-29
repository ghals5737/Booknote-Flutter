import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search/unified_search_response.dart';
import '../utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchService {
  /// 환경변수에서 Base URL 가져오기
  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:9500';
  }

  Future<String?> _getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  /// 통합 검색 API 호출
  Future<UnifiedSearchData> unifiedSearch({
    required String query,
    String type = 'all',
    int page = 1,
    int size = 10,
  }) async {
    if (query.trim().isEmpty || query.length < 2) {
      return UnifiedSearchData(
        books: [],
        notes: [],
        quotes: [],
        suggestions: [],
      );
    }

    final queryParams = {
      'query': query,
      'type': type,
      'page': page.toString(),
      'size': size.toString(),
    };

    final url = Uri.parse('$baseUrl/api/v1/search/unified')
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
        
        final searchResponse = UnifiedSearchResponse.fromJson(jsonMap);
        
        if (searchResponse.success && searchResponse.data != null) {
          return searchResponse.data!;
        } else {
          throw Exception(searchResponse.message);
        }
      } else {
        throw Exception('Failed to search');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }
}

