// lib/models/search/unified_search_response.dart

class UnifiedSearchResponse {
  final bool success;
  final int status;
  final String message;
  final UnifiedSearchData? data;
  final String timestamp;

  UnifiedSearchResponse({
    required this.success,
    required this.status,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory UnifiedSearchResponse.fromJson(Map<String, dynamic> json) {
    return UnifiedSearchResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? UnifiedSearchData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class UnifiedSearchData {
  final List<UnifiedBookItem> books;
  final List<UnifiedNoteItem> notes;
  final List<UnifiedQuoteItem> quotes;
  final List<String> suggestions;

  UnifiedSearchData({
    required this.books,
    required this.notes,
    required this.quotes,
    required this.suggestions,
  });

  factory UnifiedSearchData.fromJson(Map<String, dynamic> json) {
    return UnifiedSearchData(
      books: (json['books'] as List?)
              ?.map((e) => UnifiedBookItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: (json['notes'] as List?)
              ?.map((e) => UnifiedNoteItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quotes: (json['quotes'] as List?)
              ?.map((e) => UnifiedQuoteItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suggestions: (json['suggestions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class UnifiedBookItem {
  final int id;
  final String title;
  final String? author;
  final int? notesCount;
  final int? quotesCount;

  UnifiedBookItem({
    required this.id,
    required this.title,
    this.author,
    this.notesCount,
    this.quotesCount,
  });

  factory UnifiedBookItem.fromJson(Map<String, dynamic> json) {
    return UnifiedBookItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'],
      notesCount: json['notesCount'],
      quotesCount: json['quotesCount'],
    );
  }
}

class UnifiedNoteItem {
  final int id;
  final int bookId;
  final String title;
  final String? bookTitle;
  final String? snippet;
  final String? content;

  UnifiedNoteItem({
    required this.id,
    required this.bookId,
    required this.title,
    this.bookTitle,
    this.snippet,
    this.content,
  });

  factory UnifiedNoteItem.fromJson(Map<String, dynamic> json) {
    return UnifiedNoteItem(
      id: json['id'] ?? 0,
      bookId: json['bookId'] ?? 0,
      title: json['title'] ?? '',
      bookTitle: json['bookTitle'],
      snippet: json['snippet'],
      content: json['content'],
    );
  }
}

class UnifiedQuoteItem {
  final int id;
  final int bookId;
  final String text;
  final String? bookTitle;
  final int? page;
  final String? chapter;

  UnifiedQuoteItem({
    required this.id,
    required this.bookId,
    required this.text,
    this.bookTitle,
    this.page,
    this.chapter,
  });

  factory UnifiedQuoteItem.fromJson(Map<String, dynamic> json) {
    return UnifiedQuoteItem(
      id: json['id'] ?? 0,
      bookId: json['bookId'] ?? 0,
      text: json['text'] ?? '',
      bookTitle: json['bookTitle'],
      page: json['page'],
      chapter: json['chapter'],
    );
  }
}

