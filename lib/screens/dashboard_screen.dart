import 'package:booknoteflutter/data/mock_data.dart';
import 'package:booknoteflutter/models/book/book.dart';
import 'package:booknoteflutter/widgets/category_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import
import 'package:go_router/go_router.dart';
import '../providers/book/book_providers.dart';
import '../widgets/book_card.dart';
import '../theme/app_theme.dart';

// StatefulWidget -> ConsumerStatefulWidget으로 변경
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  //내 서재 필터링 로직 (서버 데이터를 받아서 처리하는 함수로 변경)
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
    final recentReadBooks = ref.watch(recentReadBooksProvider);    
    final myLibraryBooks = ref.watch(myLibraryBooksProvider);

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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppTheme.headingDark,
            ),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
     body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 최근 읽은 책 섹션
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '최근 읽은 책',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      recentReadBooks.when(
                        data: (recentReadBooks) {
                          if (recentReadBooks.isEmpty) {
                            return const Text(
                              '최근 읽은 책이 없습니다',
                              style: TextStyle(
                                color: AppTheme.bodyMedium,
                                fontSize: 14,
                              ),
                            );
                          }
                          return Column(
                            children: recentReadBooks.map((book) => BookCard(
                              book: book,
                              onTap: () {
                                context.push('/book/${book.id}', extra: book);
                              },
                            )).toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('에러: $err')),
                      )
                    ],
                  ),
                ),              
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
                                style: TextStyle(color: AppTheme.bodyMedium, fontSize: 16),
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
                            // _BookGridCard는 아래에 정의되어 있다고 가정 (코드 하단 참고)
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
                                return const Icon(Icons.book, size: 40, color: AppTheme.metaLight);
                              },
                            )
                          : const Icon(Icons.book, size: 40, color: AppTheme.metaLight),
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
                  style: const TextStyle(fontSize: 12, color: AppTheme.bodyMedium),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandBlue),
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