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

  Future<Note> createNote({
    required int bookId,
    required String title,
    required String content,
    String? html,
    bool isImportant = false,
    List<String> tagList = const [],
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/notes');
    final token = await _getAccessToken();
    
    final requestBody = {
      'bookId': bookId,
      'title': title,
      'content': content,
      'html': html ?? content, // html이 없으면 content와 동일하게 설정
      'isImportant': isImportant,
      'tagList': tagList,
      'important': isImportant, // important와 isImportant 동일한 값
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
          return Note.fromJson(jsonMap['data']);
        } else {
          throw Exception(jsonMap['message'] ?? 'Failed to create note');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        throw Exception(jsonMap['message'] ?? 'Failed to create note');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<void> deleteNote(int noteId) async {
    final url = Uri.parse('$baseUrl/api/v1/notes/$noteId');
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
          throw Exception(jsonMap['message'] ?? 'Failed to delete note');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        throw Exception(jsonMap['message'] ?? 'Failed to delete note');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }

  Future<Note> updateNote({
    required int noteId,
    required int bookId,
    required String title,
    required String content,
    String? html,
    bool isImportant = false,
    List<String> tagList = const [],
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/notes/$noteId');
    final token = await _getAccessToken();
    
    final requestBody = {
      'bookId': bookId,
      'title': title,
      'content': content,
      'html': html ?? content,
      'isImportant': isImportant,
      'tagList': tagList,
      'important': isImportant,
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
      
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        
        if (jsonMap['success'] == true && jsonMap['data'] != null) {
          return Note.fromJson(jsonMap['data']);
        } else {
          throw Exception(jsonMap['message'] ?? 'Failed to update note');
        }
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final jsonMap = jsonDecode(decodedBody);
        throw Exception(jsonMap['message'] ?? 'Failed to update note');
      }
    } catch (e) {
      throw Exception('Failed to connect server: $e');
    }
  }
}

