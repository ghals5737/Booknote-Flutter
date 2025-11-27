// lib/models/book_response.dart

import 'book.dart'; // 기존 Book 모델 import

class BookRecentResponse {
  final bool success;
  final String message;
  final List<Book> data; // "data" 필드 안에 실제 컨텐츠가 있음

  BookRecentResponse({required this.success, required this.message, required this.data});

  factory BookRecentResponse.fromJson(Map<String, dynamic> json) {
    return BookRecentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => Book.fromJson(e))
              .toList() ??
          [],
    );
  }
}
