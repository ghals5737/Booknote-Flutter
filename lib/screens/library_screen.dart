import 'package:booknoteflutter/data/mock_data.dart';
import 'package:booknoteflutter/models/book/book.dart';
import 'package:booknoteflutter/widgets/category_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/book/book_providers.dart';
import '../theme/app_theme.dart';

/// 서재 화면 - 책 컬렉션에 집중, 검색 기능 포함
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  //내 서재 필터링 로직
  List<Book> _filterBooks(List<Book> books) {
    var filtered = books;

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
        filtered = filtered.where((book) => book.category == categoryName).toList();
      }
    }

    // 검색 필터링
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((book) {
        return book.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            book.author.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = MockData.getCategories();
    final myLibraryBooks = ref.watch(myLibraryBooksProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: const Text(
          '내 서재',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 검색바
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F5), // design.json grayMedium
                  borderRadius: BorderRadius.circular(12),
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
              myLibraryBooks.when(
                data: (myLibraryBooks) {
                  final books = _filterBooks(myLibraryBooks);

                  if (books.isEmpty) {
                    return const Center(
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
                    );
                  }

                  return GridView.builder(
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
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        Text('에러: $err'),
                        TextButton(
                          onPressed: () => ref.refresh(myLibraryBooksProvider),
                          child: const Text('재시도'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 96), // 하단 네비게이션 공간
            ],
          ),
        ),
      ),
    );
  }
}

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
            context.push('/book/${book.id}', extra: book);
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: book.progress / 100,
                    minHeight: 4,
                    backgroundColor: AppTheme.borderSubtle,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF5D4A3A), // design.json primary brown
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
