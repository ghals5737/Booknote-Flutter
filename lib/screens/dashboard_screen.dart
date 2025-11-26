import 'package:flutter/material.dart';
import '../models/book.dart';
import '../data/mock_data.dart';
import '../widgets/book_card.dart';
import '../widgets/category_filter.dart';
import '../theme/app_theme.dart';

/// 대시보드 화면: 최근 읽은 책 + 내 서재
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Book> get recentBooks {
    // 최근 읽은 책 3개 (진행률이 있는 책들)
    return MockData.getBooks()
        .where((book) => book.currentPage > 0)
        .toList()
      ..sort((a, b) => b.currentPage.compareTo(a.currentPage));
  }

  List<Book> get filteredBooks {
    var books = MockData.getBooks();

    // 카테고리 필터링
    if (selectedCategoryId != 'all') {
      final categoryMap = {
        'self-help': '자기계발',
        'development': '개발',
        'history': '역사',
        'fiction': '소설',
        'psychology': '심리학',
      };
      final categoryName = categoryMap[selectedCategoryId];
      if (categoryName != null) {
        books = books.where((book) => book.category == categoryName).toList();
      }
    }

    // 검색 필터링
    if (searchQuery.isNotEmpty) {
      books = books.where((book) {
        return book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            book.author.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return books;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = MockData.getCategories();
    final recent = recentBooks.take(3).toList();
    final books = filteredBooks;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.brandBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Booknote',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppTheme.surfaceWhite,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 최근 읽은 책 섹션
              if (recent.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final book in recent) BookCard(book: book),
                    ],
                  ),
                ),
              ],
              // 내 서재 섹션
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내 서재',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.headingDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 검색바
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderSubtle, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: '책 제목이나 저자로 검색...',
                          hintStyle: TextStyle(color: AppTheme.placeholder),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.metaLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 카테고리 필터
                    CategoryFilter(
                      categories: categories,
                      selectedCategoryId: selectedCategoryId,
                      onCategorySelected: (categoryId) {
                        setState(() {
                          selectedCategoryId = categoryId;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // 책 그리드
                    if (books.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            '책이 없습니다',
                            style: TextStyle(
                              color: AppTheme.bodyMedium,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return _BookGridCard(book: book);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// design.json 기반 BookGridCard
class _BookGridCard extends StatelessWidget {
  final Book book;

  const _BookGridCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 책 상세 페이지로 이동
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 책 표지
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      color: AppTheme.borderSubtle,
                      child: book.coverImageUrl != null
                          ? Image.network(
                              book.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.book,
                                  size: 40,
                                  color: AppTheme.metaLight,
                                );
                              },
                            )
                          : const Icon(
                              Icons.book,
                              size: 40,
                              color: AppTheme.metaLight,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 제목
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.headingDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // 저자
                Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.bodyMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.progress / 100,
                    minHeight: 4,
                    backgroundColor: AppTheme.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.brandBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

