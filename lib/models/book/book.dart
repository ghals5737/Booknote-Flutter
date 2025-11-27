// lib/models/book.dart
class Book {
  final int id; // 스웨거에서 id가 숫자(0)로 되어 있음
  final String title;
  final String author;
  final String? coverImageUrl; // API의 'coverImage' 매핑
  final String category;
  final int totalPages;
  final int currentPage;
  final int noteCount; // API의 'noteCnt' 매핑

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverImageUrl,
    required this.category,
    required this.totalPages,
    required this.currentPage,
    this.noteCount = 0,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      // API 필드명 'coverImage'를 앱 내부 변수 'coverImageUrl'로 매핑
      coverImageUrl: json['coverImage'], 
      category: json['category'] ?? '기타',
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      // API 필드명 'noteCnt'를 'noteCount'로 매핑
      noteCount: json['noteCnt'] ?? 0, 
    );
  }
  
  // 진행률 계산 getter 등...
  double get progress {
    if (totalPages == 0) return 0;
    return (currentPage / totalPages) * 100;
  }
}