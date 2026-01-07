import '../note/note.dart';
import '../quote/quote.dart';

class TodayReviewResponse {
  final bool success;
  final int status;
  final String message;
  final TodayReviewData data;

  TodayReviewResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory TodayReviewResponse.fromJson(Map<String, dynamic> json) {
    return TodayReviewResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: TodayReviewData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class TodayReviewData {
  final int id;
  final DateTime? plannedTime;
  final DateTime? completedTime;
  final List<ReviewItem> items;
  final String? nextReviewDate;

  TodayReviewData({
    required this.id,
    this.plannedTime,
    this.completedTime,
    required this.items,
    this.nextReviewDate,
  });

  factory TodayReviewData.fromJson(Map<String, dynamic> json) {
    return TodayReviewData(
      id: json['id'] ?? 0,
      plannedTime: json['plannedTime'] != null
          ? DateTime.parse(json['plannedTime'])
          : null,
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'])
          : null,
      items: (json['items'] as List?)
              ?.map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextReviewDate: json['nextReviewDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plannedTime': plannedTime?.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'nextReviewDate': nextReviewDate,
    };
  }
}

class ReviewItem {
  final int id;
  final int reviewId;
  final String itemType;
  final int itemId;
  final bool completed;
  final DateTime? completedTime;
  final Note? note;
  final Quote? quote;
  final String bookTitle;
  final DateTime? lastReviewTime;
  final int reviewCount;
  final String? nextReviewDate;
  final int postponeCount;

  ReviewItem({
    required this.id,
    required this.reviewId,
    required this.itemType,
    required this.itemId,
    required this.completed,
    this.completedTime,
    this.note,
    this.quote,
    required this.bookTitle,
    this.lastReviewTime,
    required this.reviewCount,
    this.nextReviewDate,
    required this.postponeCount,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      id: json['id'] ?? 0,
      reviewId: json['reviewId'] ?? 0,
      itemType: json['itemType'] ?? '',
      itemId: json['itemId'] ?? 0,
      completed: json['completed'] ?? false,
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'])
          : null,
      note: json['note'] != null
          ? Note.fromJson(json['note'] as Map<String, dynamic>)
          : null,
      quote: json['quote'] != null
          ? Quote.fromJson(json['quote'] as Map<String, dynamic>)
          : null,
      bookTitle: json['bookTitle'] ?? '',
      lastReviewTime: json['lastReviewTime'] != null
          ? DateTime.parse(json['lastReviewTime'])
          : null,
      reviewCount: json['reviewCount'] ?? 0,
      nextReviewDate: json['nextReviewDate'],
      postponeCount: json['postponeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewId': reviewId,
      'itemType': itemType,
      'itemId': itemId,
      'completed': completed,
      'completedTime': completedTime?.toIso8601String(),
      'note': note != null ? _noteToJson(note!) : null,
      'quote': quote != null ? _quoteToJson(quote!) : null,
      'bookTitle': bookTitle,
      'lastReviewTime': lastReviewTime?.toIso8601String(),
      'reviewCount': reviewCount,
      'nextReviewDate': nextReviewDate,
      'postponeCount': postponeCount,
    };
  }

  Map<String, dynamic> _noteToJson(Note note) {
    return {
      'id': note.id,
      'bookId': note.bookId,
      'title': note.title,
      'content': note.content,
      'page': note.page,
      'tags': note.tags,
      'createdAt': note.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _quoteToJson(Quote quote) {
    return {
      'id': quote.id,
      'bookId': quote.bookId,
      'content': quote.text,
      'page': quote.page,
      'memo': quote.comment,
      'tags': quote.tags,
      'createdAt': quote.createdAt.toIso8601String(),
      'isImportant': quote.isImportant,
    };
  }
}

class ReviewHistoryResponse {
  final bool success;
  final int status;
  final String message;
  final ReviewHistoryPageData data;
  final String timestamp;

  ReviewHistoryResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory ReviewHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReviewHistoryResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: ReviewHistoryPageData.fromJson(json['data'] ?? {}),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class ReviewHistoryPageData {
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
  final int size;
  final List<ReviewHistorySession> content;
  final int number;
  final int numberOfElements;
  final bool empty;

  ReviewHistoryPageData({
    required this.totalPages,
    required this.totalElements,
    required this.first,
    required this.last,
    required this.size,
    required this.content,
    required this.number,
    required this.numberOfElements,
    required this.empty,
  });

  factory ReviewHistoryPageData.fromJson(Map<String, dynamic> json) {
    return ReviewHistoryPageData(
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      size: json['size'] ?? 0,
      content: (json['content'] as List?)
              ?.map((e) => ReviewHistorySession.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      number: json['number'] ?? 0,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}

class ReviewHistorySession {
  final int id;
  final bool completed;
  final DateTime? plannedTime;
  final DateTime? completedTime;
  final List<ReviewItem> reviewItems;

  ReviewHistorySession({
    required this.id,
    required this.completed,
    this.plannedTime,
    this.completedTime,
    required this.reviewItems,
  });

  factory ReviewHistorySession.fromJson(Map<String, dynamic> json) {
    return ReviewHistorySession(
      id: json['id'] ?? 0,
      completed: json['completed'] ?? false,
      plannedTime: json['plannedTime'] != null
          ? DateTime.parse(json['plannedTime'])
          : null,
      completedTime: json['completedTime'] != null
          ? DateTime.parse(json['completedTime'])
          : null,
      reviewItems: (json['reviewItems'] as List?)
              ?.map((e) => ReviewItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
