// lib/models/book_response.dart

import 'book.dart'; // 기존 Book 모델 import

class BookResponse {
  final bool success;
  final String message;
  final BookPage data; // "data" 필드 안에 실제 컨텐츠가 있음

  BookResponse({required this.success, required this.message, required this.data});

  factory BookResponse.fromJson(Map<String, dynamic> json) {
    return BookResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: BookPage.fromJson(json['data']),
    );
  }
}

class BookPage {
  final List<Book> content; // 실제 책 리스트
  final int totalPages;
  final int totalElements;
  final bool last;

  BookPage({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      content: (json['content'] as List?)
              ?.map((e) => Book.fromJson(e))
              .toList() ??
          [],
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      last: json['last'] ?? true,
    );
  }
}