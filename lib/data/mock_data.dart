import '../models/book/book.dart';
import '../models/category.dart';

class MockData {
  static List<Book> getBooks() {
    return [
      Book(
        id: 1,
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
}

