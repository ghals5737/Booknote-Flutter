/// 책 검색 응답 모델
class BookSearchResponse {
  final bool success;
  final int status;
  final String message;
  final List<BookSearchResult> data;
  final String timestamp;

  BookSearchResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory BookSearchResponse.fromJson(Map<String, dynamic> json) {
    return BookSearchResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => BookSearchResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? '',
    );
  }
}

/// 책 검색 결과 모델
class BookSearchResult {
  final String title;
  final String? link;
  final String? image;
  final String? author;
  final String? discount;
  final String? publisher;
  final String? pubdate;
  final String? isbn;
  final String? description;

  BookSearchResult({
    required this.title,
    this.link,
    this.image,
    this.author,
    this.discount,
    this.publisher,
    this.pubdate,
    this.isbn,
    this.description,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      title: json['title'] ?? '',
      link: json['link'],
      image: json['image'],
      author: json['author'],
      discount: json['discount'],
      publisher: json['publisher'],
      pubdate: json['pubdate'],
      isbn: json['isbn'],
      description: json['description'],
    );
  }
}

