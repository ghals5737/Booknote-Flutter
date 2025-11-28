class Quote {
  final int id;
  final int bookId;
  final String text;
  final int page;
  final String? comment;
  final List<String> tags;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.bookId,
    required this.text,
    required this.page,
    this.comment,
    this.tags = const [],
    required this.createdAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    // API 스펙: content 필드가 text로 매핑됨
    // API 스펙: memo 필드가 comment로 매핑됨
    // API 스펙: createdAt이 없으므로 현재 시간 사용
    return Quote(
      id: json['id'],
      bookId: json['bookId'],
      text: json['content'] ?? '', // API의 'content' 필드를 'text'로 매핑
      page: json['page'] ?? 0,
      comment: json['memo'], // API의 'memo' 필드를 'comment'로 매핑
      tags: [], // API 스펙에 tags 필드가 없음
      createdAt: DateTime.now(), // API 스펙에 createdAt이 없음
    );
  }
}

