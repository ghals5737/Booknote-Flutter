import 'package:flutter/material.dart';
import '../models/book.dart';
import '../data/mock_data.dart';
import '../widgets/book_card.dart';
import '../widgets/category_filter.dart';
import '../theme/app_theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String selectedCategoryId = 'all';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    final books = filteredBooks;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('내 서재'),
        centerTitle: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // 정렬 기능 (추후 구현)
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                // 책 추가 기능 (추후 구현)
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('책 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
        children: [
          // 검색바 (design.json: borderRadius 8px, height 48px)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '책 제목이나 저자로 검색...',
                  hintStyle: const TextStyle(color: AppTheme.placeholder),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.metaLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
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
          ),
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
          // 책 목록
          Expanded(
            child: books.isEmpty
                ? const Center(
                    child: Text(
                      '책이 없습니다',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: books[index],
                        onTap: () {
                          // 책 상세 페이지로 이동 (추후 구현)
                        },
                      );
                    },
                  ),
          ),
        ],
        ),
      ),
    );
  }
}

