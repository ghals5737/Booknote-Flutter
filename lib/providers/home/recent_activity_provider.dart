import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../book/book_providers.dart';
import '../note/note_providers.dart';
import '../quote/quote_providers.dart';

/// 홈 화면 "최근 활동"용 아이템
class RecentActivityItem {
  final bool isQuote;
  final String text;
  final String bookTitle;
  final DateTime createdAt;
  final int bookId;
  final int itemId; // quote id or note id

  const RecentActivityItem({
    required this.isQuote,
    required this.text,
    required this.bookTitle,
    required this.createdAt,
    required this.bookId,
    required this.itemId,
  });
}

/// 최근 읽은 책의 노트·인용구를 합쳐 최신순으로 반환 (에러 시 빈 목록 반환)
final recentActivityProvider = FutureProvider<List<RecentActivityItem>>((ref) async {
  try {
    final books = await ref.read(recentReadBooksProvider.future);
    final items = <RecentActivityItem>[];

    for (final book in books.take(3)) {
      try {
        final quotes = await ref.read(quotesForBookProvider(book.id).future);
        final notes = await ref.read(notesForBookProvider(book.id).future);
        for (final q in quotes) {
          items.add(RecentActivityItem(
            isQuote: true,
            text: q.text,
            bookTitle: book.title,
            createdAt: q.createdAt,
            bookId: book.id,
            itemId: q.id,
          ));
        }
        for (final n in notes) {
          items.add(RecentActivityItem(
            isQuote: false,
            text: n.title,
            bookTitle: book.title,
            createdAt: n.createdAt,
            bookId: book.id,
            itemId: n.id,
          ));
        }
      } catch (_) {
        // 개별 책 로드 실패 시 스킵
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.take(10).toList();
  } catch (_) {
    return [];
  }
});
