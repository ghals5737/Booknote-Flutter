import 'book.dart';

class BookDetailResponse {
  final bool success;
  final int status;
  final String message;
  final BookDetailData data;
  final String timestamp;

  BookDetailResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory BookDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookDetailResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: BookDetailData.fromJson(json['data']),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class BookDetailData {
  final int id;
  final String title;
  final String author;
  final String? description;
  final DateTime? startDate;
  final DateTime? updateDate;
  final double progress;
  final int totalPages;
  final int currentPage;
  final String category;
  final int rating;
  final String? coverImage;
  final String? publisher;
  final String? isbn;

  BookDetailData({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.startDate,
    this.updateDate,
    required this.progress,
    required this.totalPages,
    required this.currentPage,
    required this.category,
    required this.rating,
    this.coverImage,
    this.publisher,
    this.isbn,
  });

  factory BookDetailData.fromJson(Map<String, dynamic> json) {
    return BookDetailData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
      progress: (json['progress'] ?? 0).toDouble(),
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      category: json['category'] ?? '기타',
      rating: json['rating'] ?? 0,
      coverImage: json['coverImage'],
      publisher: json['publisher'],
      isbn: json['isbn'],
    );
  }

  // Book 모델로 변환
  Book toBook() {
    return Book(
      id: id,
      title: title,
      author: author,
      coverImageUrl: coverImage,
      category: category,
      totalPages: totalPages,
      currentPage: currentPage,
      noteCount: 0, // 상세 정보에는 noteCount가 없으므로 0으로 설정
    );
  }
}

