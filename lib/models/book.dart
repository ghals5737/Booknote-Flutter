class Book {
  final String id;
  final String title;
  final String author;
  final String? coverImageUrl;
  final String category;
  final int totalPages;
  final int currentPage;
  final int noteCount;
  final double? rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverImageUrl,
    required this.category,
    required this.totalPages,
    required this.currentPage,
    this.noteCount = 0,
    this.rating,
  });

  double get progress {
    if (totalPages == 0) return 0;
    return (currentPage / totalPages) * 100;
  }
}

