import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note/note.dart';
import '../models/note/note_response.dart';
import '../utils/token_storage.dart';

class NoteService {
  final String baseUrl = 'http://10.0.2.2:9500';

  Future<String?> _getAccessToken() async {
    return await TokenStorage.getAccessToken();
  }

  Future<List<Note>> getNotesForBook(
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
    
    final url = Uri.parse('$baseUrl/api/v1/notes/user/books/$bookId')
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
        
        final noteResponse = NoteResponse.fromJson(jsonMap);
        
        if (noteResponse.success) {
          return noteResponse.data.content;
        } else {
          throw Exception(noteResponse.message);
        }
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }
}

