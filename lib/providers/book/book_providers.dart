import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/book_service.dart';
import '../../models/book/book.dart';
import '../../models/book/book_detail_response.dart';
import '../../models/note/note.dart';
import '../../models/quote/quote.dart';
import '../note/note_providers.dart';
import '../quote/quote_providers.dart';

final bookServiceProvider = Provider<BookService>((ref) {
  return BookService();
});

final myLibraryBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getUserBooks();
});

final recentReadBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getRecentReadBooks(7);
});

final bookDetailProvider = FutureProvider.family<BookDetailData, int>((ref, bookId) async {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getBookDetail(bookId);
});

/// 책 상세 정보, 노트, 인용구를 병렬로 가져오는 통합 Provider
final bookFullDataProvider = FutureProvider.family<(BookDetailData, List<Note>, List<Quote>), int>((ref, bookId) async {
  // Future.wait로 병렬 처리
  final results = await Future.wait([
    ref.read(bookDetailProvider(bookId).future),
    ref.read(notesForBookProvider(bookId).future),
    ref.read(quotesForBookProvider(bookId).future),
  ]);

  // 타입 캐스팅하여 Record로 반환 (순서대로)
  return (
    results[0] as BookDetailData,
    results[1] as List<Note>,
    results[2] as List<Quote>,
  );
});