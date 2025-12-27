import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote/quote.dart';
import '../models/quote/quote_response.dart';
import '../utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuoteService {
  /// 환경변수에서 Base URL 가져오기
  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:9500';
  }

  Future<String?> _getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  Future<List<Quote>> getQuotesForBook(
    int bookId, {
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    if (sort != null) {
      queryParams['sort'] = sort;
    }
    
    final url = Uri.parse('$baseUrl/api/v1/quotes/user/books/$bookId')
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
        
        final quoteResponse = QuoteResponse.fromJson(jsonMap);
        
        if (quoteResponse.success) {
          return quoteResponse.data.content;
        } else {
          throw Exception(quoteResponse.message);
        }
      } else {
        throw Exception('Failed to load quotes');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<Quote> createQuote({
    required int bookId,
    required String text,
    required int page,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/quotes');
    final token = await _getAccessToken();
    
    final requestBody = {
      'bookId': bookId,
      'text': text,
      'page': page,
    };
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        
        if (jsonMap['success'] == true && jsonMap['data'] != null) {
          return Quote.fromJson(jsonMap['data']);
        } else {
          throw Exception(jsonMap['message'] ?? 'Failed to create quote');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        throw Exception(jsonMap['message'] ?? 'Failed to create quote');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<void> deleteQuote(int quoteId) async {
    final url = Uri.parse('$baseUrl/api/v1/quotes/$quoteId');
    final token = await _getAccessToken();
    
    try {
      final response = await http.delete(
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
        
        if (jsonMap['success'] != true) {
          throw Exception(jsonMap['message'] ?? 'Failed to delete quote');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        throw Exception(jsonMap['message'] ?? 'Failed to delete quote');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<Quote> updateQuote({
    required int quoteId,
    required String content,
    required int page,
    String? memo,
    required bool isImportant,
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/quotes/$quoteId');
    final token = await _getAccessToken();
    
    final requestBody = {
      'content': content,
      'page': page,
      'memo': memo ?? '', // memo는 빈 문자열로라도 포함
      'isImportant': isImportant,
    };
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      
      final decodedBody = utf8.decode(response.bodyBytes);
      final jsonMap = jsonDecode(decodedBody);
      
      if (response.statusCode == 200) {
        if (jsonMap['success'] == true && jsonMap['data'] != null) {
          return Quote.fromJson(jsonMap['data']);
        } else {
          throw Exception(jsonMap['message'] ?? 'Failed to update quote');
        }
      } else {
        throw Exception(jsonMap['message'] ?? 'Failed to update quote (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to connect server: $e');
    }
  }
}

