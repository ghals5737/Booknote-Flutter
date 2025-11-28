class Note {
  final int id;
  final int bookId;
  final String title;
  final String content;
  final int page;
  final List<String> tags;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.bookId,
    required this.title,
    required this.content,
    required this.page,
    this.tags = const [],
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    // API 스펙: tagList 우선, 없으면 tagName 사용
    List<String> tags = [];
    if (json['tagList'] != null && (json['tagList'] as List).isNotEmpty) {
      tags = List<String>.from(json['tagList']);
    } else if (json['tagName'] != null && json['tagName'].toString().isNotEmpty) {
      tags = [json['tagName'].toString()];
    }

    // API 스펙: page는 nullable이지만 앱에서는 required
    int page = json['page'] ?? 0;

    // API 스펙: startDate 우선, 없으면 updateDate, 둘 다 없으면 현재 시간
    DateTime createdAt;
    if (json['startDate'] != null) {
      createdAt = DateTime.parse(json['startDate']);
    } else if (json['updateDate'] != null) {
      createdAt = DateTime.parse(json['updateDate']);
    } else {
      createdAt = DateTime.now();
    }

    return Note(
      id: json['id'],
      bookId: json['bookId'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      page: page,
      tags: tags,
      createdAt: createdAt,
    );
  }
}

