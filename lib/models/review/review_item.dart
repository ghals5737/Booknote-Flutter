import '../note/note.dart';
import '../quote/quote.dart';

/// 복습 항목 (노트 또는 인용구)
class ReviewItem {
  final String id; // 고유 ID (note-{id} 또는 quote-{id})
  final bool isNote;
  final Note? note;
  final Quote? quote;
  final String bookTitle; // 책 제목
  final String category; // 카테고리
  final String priority; // 우선순위: '높음', '보통', '낮음'
  final int reviewCount; // 복습 횟수
  final DateTime lastReviewDate; // 마지막 복습 날짜

  ReviewItem({
    required this.id,
    required this.isNote,
    this.note,
    this.quote,
    required this.bookTitle,
    required this.category,
    required this.priority,
    required this.reviewCount,
    required this.lastReviewDate,
  });

  String get title => isNote ? (note?.title ?? '') : (quote?.text ?? '');
  String get content => isNote ? (note?.content ?? '') : (quote?.text ?? '');
  String get text => isNote ? (note?.content ?? '') : (quote?.text ?? '');
  int get page => isNote ? (note?.page ?? 0) : (quote?.page ?? 0);
}

