import 'dart:convert';
import 'package:booknoteflutter/models/book/book_recnt_response.dart';
import 'package:http/http.dart' as http;
import '../models/book/book.dart';
import '../models/book/book_response.dart';

class BookService {
  final String baseUrl = 'http://10.0.2.2:9500';
  final String accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0dHRAdHR0IiwidWlkIjo0NCwiaWF0IjoxNzY0MjI0OTYwLCJleHAiOjE3NjY4MTY5NjB9.s-MzjjGYgJmMq42nv7vtD8KxI_XqmrsstY0nqffEPRs";

  Future<List<Book>> getUserBooks() async {
    final url = Uri.parse('$baseUrl/api/v1/user/books?page=0&size=20'); 
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken', // 여기에 토큰을 넣습니다.
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
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken', // 여기에 토큰을 넣습니다.
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
}