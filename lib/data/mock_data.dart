import '../models/book.dart';
import '../models/category.dart';

class MockData {
  static List<Book> getBooks() {
    return [
      Book(
        id: '1',
        title: '삶으로 다시 떠오르기 수정 (자유 영혼을 위한 플레이의 대화)',
        author: '에크하르트 톨레',
        category: '자기계발',
        totalPages: 320,
        currentPage: 1,
        noteCount: 0,
      ),
      Book(
        id: '2',
        title: '아토믹 해빗',
        author: '제임스 클리어',
        category: '자기계발',
        totalPages: 320,
        currentPage: 240,
        noteCount: 12,
      ),
      Book(
        id: '3',
        title: '클린 코드',
        author: '로버트 C. 마틴',
        category: '개발',
        totalPages: 464,
        currentPage: 208,
        noteCount: 8,
      ),
      Book(
        id: '4',
        title: '사피엔스',
        author: '유발 하라리',
        category: '역사',
        totalPages: 512,
        currentPage: 461,
        noteCount: 22,
      ),
      Book(
        id: '5',
        title: '소설책 예시',
        author: '작가명',
        category: '소설',
        totalPages: 300,
        currentPage: 150,
        noteCount: 5,
      ),
      Book(
        id: '6',
        title: '심리학 책 예시',
        author: '심리학자',
        category: '심리학',
        totalPages: 400,
        currentPage: 200,
        noteCount: 10,
      ),
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

