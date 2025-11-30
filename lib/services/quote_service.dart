import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote/quote.dart';
import '../models/quote/quote_response.dart';
import '../utils/token_storage.dart';

class QuoteService {
  final String baseUrl = 'http://10.0.2.2:9500';

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
}

