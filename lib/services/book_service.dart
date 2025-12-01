import 'dart:convert';
import 'package:booknoteflutter/models/book/book_recnt_response.dart';
import 'package:http/http.dart' as http;
import '../models/book/book.dart';
import '../models/book/book_response.dart';
import '../models/book/book_detail_response.dart';
import '../utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BookService {
  /// 환경변수에서 Base URL 가져오기
  String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:9500';
  }

  Future<String?> _getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  Future<List<Book>> getUserBooks() async {
    final url = Uri.parse('$baseUrl/api/v1/user/books?page=0&size=20');
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
        final decodedBody=utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);

        final bookResponse = BookResponse.fromJson(jsonMap);

        if(bookResponse.success){
          return bookResponse.data.content;
        } else {
          throw Exception(bookResponse.message);
        }
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<List<Book>> getRecentReadBooks(int days) async {
    final url = Uri.parse('$baseUrl/api/v1/users/books/recent/$days');
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
        final decodedBody=utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);

        final bookRecentResponse = BookRecentResponse.fromJson(jsonMap);

        if(bookRecentResponse.success){
          return bookRecentResponse.data;
        } else {
          throw Exception(bookRecentResponse.message);
        }
      } else {
        throw Exception('Failed to load recent books');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<BookDetailData> getBookDetail(int bookId) async {
    final url = Uri.parse('$baseUrl/api/v1/user/books/$bookId');
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
        
        final bookDetailResponse = BookDetailResponse.fromJson(jsonMap);
        
        if (bookDetailResponse.success) {
          return bookDetailResponse.data;
        } else {
          throw Exception(bookDetailResponse.message);
        }
      } else {
        throw Exception('Failed to load book detail');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }
}