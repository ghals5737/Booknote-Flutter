import '../models/book/book.dart';
import '../models/category.dart';
import '../models/note/note.dart';
import '../models/quote/quote.dart';
import '../models/review/review_item.dart';

class MockData {
  static List<Book> getBooks() {
    return [
      Book(
        id: 1,
        title: '아토믹 해빗',
        author: '제임스 클리어',
        category: '자기계발',
        totalPages: 320,
        currentPage: 240,
        noteCount: 2,
      ),
      Book(
        id: 2,
        title: '삶으로 다시 떠오르기 수정 (자유 영혼을 위한 플레이의 대화)',
        author: '에크하르트 톨레',
        category: '자기계발',
        totalPages: 320,
        currentPage: 1,
        noteCount: 0,
      )
    ];
  }

  static List<Category> getCategories() {
    return [
      Category(id: 'all', name: '전체', count: 6),
      Category(id: 'self-help', name: '자기계발', count: 2),
      Category(id: 'development', name: '개발', count: 1),
      Category(id: 'history', name: '역사', count: 1),
      Category(id: 'fiction', name: '소설', count: 1),
      Category(id: 'psychology', name: '심리학', count: 1),
    ];
  }

  static List<Note> getNotesForBook(int bookId) {
    if (bookId == 1) {
      return [
        Note(
          id: 1,
          bookId: 1,
          title: '습관의 복리 효과',
          content:
              '1%의 개선이 1년 후에는 37배의 향상을 가져온다. 작은 변화가 시간이 지나면서 놀라운 결과를 만들어낸다.',
          page: 15,
          tags: ['복리효과', '개선'],
          createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        ),
        Note(
          id: 2,
          bookId: 1,
          title: '정체성 기반 습관',
          content:
              '결과가 아닌 정체성에 집중하라. "나는 건강한 사람이다"라고 생각하는 사람이 "나는 살을 빼고 싶다"라고 생각하는 사람보다 더 나은 결과를 얻는다.',
          page: 45,
          tags: ['정체성', '습관'],
          createdAt: DateTime.parse('2024-01-14T15:20:00Z'),
        ),
      ];
    }
    return [];
  }

  static List<Quote> getQuotesForBook(int bookId) {
    if (bookId == 1) {
      return [
        Quote(
          id: 1,
          bookId: 1,
          text: '실패는 성공의 어머니다. 실패를 두려워하지 말고 계속 시도하라.',
          page: 78,
          tags: ['성공', '실패'],
          createdAt: DateTime.parse('2024-01-16T14:20:00Z'),
        ),
        Quote(
          id: 2,
          bookId: 1,
          text: '성공은 준비된 자에게 기회가 왔을 때 만들어진다.',
          page: 45,
          tags: ['성공', '준비'],
          createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        ),
        Quote(
          id: 3,
          bookId: 1,
          text: '작은 습관이 큰 변화를 만든다.',
          page: 12,
          tags: ['습관', '변화'],
          createdAt: DateTime.parse('2024-01-13T09:15:00Z'),
        ),
      ];
    }
    return [];
  }

  static List<_Activity> getRecentActivitiesForBook(int bookId) {
    if (bookId == 1) {
      final notes = getNotesForBook(bookId);
      final quotes = getQuotesForBook(bookId);
      final activities = <_Activity>[];

      // 인용구를 활동으로 변환
      for (var quote in quotes) {
        activities.add(_Activity(
          isNote: false,
          text: quote.text,
          page: quote.page,
          createdAt: quote.createdAt,
        ));
      }

      // 노트를 활동으로 변환
      for (var note in notes) {
        activities.add(_Activity(
          isNote: true,
          text: note.title,
          page: note.page,
          createdAt: note.createdAt,
        ));
      }

      // 날짜순으로 정렬 (최신순)
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return activities.take(4).toList();
    }
    return [];
  }
}

// 최근 활동을 위한 간단한 클래스
class _Activity {
  final bool isNote;
  final String text;
  final int page;
  final DateTime createdAt;

  _Activity({
    required this.isNote,
    required this.text,
    required this.page,
    required this.createdAt,
  });
}

// 복습 항목 목록
extension MockReviewData on MockData {
  static List<ReviewItem> getReviewItems() {
    final notes = MockData.getNotesForBook(1);
    final quotes = MockData.getQuotesForBook(1);
    final items = <ReviewItem>[];

    // 노트를 복습 항목으로 변환
    if (notes.isNotEmpty) {
      items.add(ReviewItem(
        id: 'note-${notes[0].id}',
        isNote: true,
        note: notes[0],
        bookTitle: '아토믹 해빗',
        category: '아토믹 해빗',
        priority: '높음',
        reviewCount: 3,
        lastReviewDate: DateTime.parse('2024-01-10'),
      ));
    }

    // 인용구를 복습 항목으로 변환
    if (quotes.isNotEmpty) {
      items.add(ReviewItem(
        id: 'quote-${quotes[0].id}',
        isNote: false,
        quote: quotes[0],
        bookTitle: '아토믹 해빗',
        category: '아토믹 해빗',
        priority: '높음',
        reviewCount: 5,
        lastReviewDate: DateTime.parse('2024-01-11'),
      ));
    }

    // 추가 노트 (클린 코드)
    items.add(ReviewItem(
      id: 'note-3',
      isNote: true,
      note: Note(
        id: 3,
        bookId: 2,
        title: '클린 코드의 원칙',
        content: '코드는 읽기 쉽고 이해하기 쉬워야 한다. 의미 있는 이름을 사용하고, 함수는 한 가지 일만 해야 한다.',
        page: 45,
        tags: ['코드', '원칙'],
        createdAt: DateTime.parse('2024-01-12T10:00:00Z'),
      ),
      bookTitle: '클린 코드',
      category: '클린 코드',
      priority: '보통',
      reviewCount: 2,
      lastReviewDate: DateTime.parse('2024-01-12'),
    ));

    return items;
  }
}

