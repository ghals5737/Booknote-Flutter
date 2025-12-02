import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/book/book_search_response.dart';
import '../providers/book/book_providers.dart';
import '../data/mock_data.dart';

/// 책 추가 화면
class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publisherController = TextEditingController();
  final _pubdateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isSearching = false;
  List<BookSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedCoverImageUrl;
  String? _selectedCategory;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _pubdateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    // API 호출
    final bookService = ref.read(bookServiceProvider);
    bookService.searchBooks(query).then((results) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = results;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 중 오류가 발생했습니다: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _selectBook(BookSearchResult book) {
    setState(() {
      _titleController.text = book.title;
      _authorController.text = book.author ?? '';
      _isbnController.text = book.isbn ?? '';
      _publisherController.text = book.publisher ?? '';
      _pubdateController.text = book.pubdate ?? '';
      _descriptionController.text = book.description ?? '';
      _selectedCoverImageUrl = book.image;
      _isSearching = false;
      _searchResults = [];
    });
  }

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리를 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final bookService = ref.read(bookServiceProvider);
      await bookService.addBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _selectedCategory!,
        totalPages: int.parse(_pagesController.text.trim()),
        isbn: _isbnController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        imgUrl: _selectedCoverImageUrl,
        publisher: _publisherController.text.trim().isNotEmpty
            ? _publisherController.text.trim()
            : null,
        pubdate: _pubdateController.text.trim().isNotEmpty
            ? _pubdateController.text.trim()
            : null,
      );

      if (mounted) {
        // Provider 무효화하여 책 목록 새로고침
        ref.invalidate(myLibraryBooksProvider);
        ref.invalidate(recentReadBooksProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('책이 추가되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('책 추가 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool _canAddBook() {
    return _titleController.text.trim().isNotEmpty &&
        _authorController.text.trim().isNotEmpty &&
        _pagesController.text.trim().isNotEmpty &&
        _isbnController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        !_isSaving;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
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
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      const Text(
                        '새 책 추가',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '읽고 싶은 책이나 읽고 있는 책을 추가해보세요.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.metaLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 책 표지 섹션
                      const Text(
                        '책 표지',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // TODO: 이미지 선택 기능
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('이미지 선택 기능은 준비 중입니다'),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // 내용
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _selectedCoverImageUrl != null
                                    ? Image.network(
                                        _selectedCoverImageUrl!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildPlaceholder();
                                        },
                                      )
                                    : _buildPlaceholder(),
                              ),
                              // 점선 테두리
                              CustomPaint(
                                painter: _DashedBorderPainter(),
                                size: Size(double.infinity, 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // 책 정보 섹션
                      const Text(
                        '책 정보',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 책 제목
                      const Text(
                        '책 제목',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '책 제목을 입력하세요',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: AppTheme.metaLight,
                            ),
                            onPressed: () {
                              _performSearch(_titleController.text);
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                        onChanged: (value) {
                          setState(() {});
                          if (value.isNotEmpty) {
                            _performSearch(value);
                          } else {
                            setState(() {
                              _isSearching = false;
                              _searchResults = [];
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '책 제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      
                      // 검색 결과
                      if (_isSearching && _searchResults.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.borderSubtle,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _searchResults.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: AppTheme.divider,
                                  ),
                                  itemBuilder: (context, index) {
                                    final book = _searchResults[index];
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () => _selectBook(book),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // 책 표지 썸네일
                                              Container(
                                                width: 50,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.divider,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: book.image != null && book.image!.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(4),
                                                        child: Image.network(
                                                          book.image!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Icon(
                                                              Icons.image,
                                                              color: AppTheme.metaLight,
                                                              size: 24,
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.image,
                                                        color: AppTheme.metaLight,
                                                        size: 24,
                                                      ),
                                              ),
                                              const SizedBox(width: 12),
                                              // 책 정보
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      book.title,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppTheme.headingDark,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    if (book.author != null && book.author!.isNotEmpty)
                                                      Text(
                                                        book.author!,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppTheme.metaLight,
                                                        ),
                                                      ),
                                                    if (book.publisher != null && book.publisher!.isNotEmpty) ...[
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        book.publisher!,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppTheme.metaLight,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // 저자
                      const Text(
                        '저자',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _authorController,
                        decoration: InputDecoration(
                          hintText: '저자명을 입력하세요',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '저자명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // ISBN (필수)
                      const Text(
                        'ISBN',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _isbnController,
                        decoration: InputDecoration(
                          hintText: 'ISBN을 입력하세요',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'ISBN을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // 카테고리 (필수)
                      const Text(
                        '카테고리',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: '카테고리를 선택하세요',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        items: MockData.getCategories()
                            .where((cat) => cat.id != 'all')
                            .map((category) {
                          return DropdownMenuItem<String>(
                            value: category.name,
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.headingDark,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '카테고리를 선택해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // 총 페이지 수
                      const Text(
                        '총 페이지 수',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pagesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '총 페이지 수',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '총 페이지 수를 입력해주세요';
                          }
                          final pages = int.tryParse(value);
                          if (pages == null || pages <= 0) {
                            return '올바른 페이지 수를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // 출판사 (선택)
                      const Text(
                        '출판사',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _publisherController,
                        decoration: InputDecoration(
                          hintText: '출판사를 입력하세요 (선택)',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 출판일 (선택)
                      const Text(
                        '출판일',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pubdateController,
                        decoration: InputDecoration(
                          hintText: '출판일을 입력하세요 (선택, 예: 2024-01-01)',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 설명 (선택)
                      const Text(
                        '설명',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: '책에 대한 설명을 입력하세요 (선택)',
                          hintStyle: TextStyle(
                            color: AppTheme.placeholder,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                    child: ElevatedButton(
                    onPressed: _canAddBook() ? _addBook : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canAddBook()
                          ? AppTheme.brandBlue
                          : AppTheme.metaLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '책 추가하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.divider,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.image_outlined,
            color: AppTheme.metaLight,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '표지 이미지',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.metaLight,
          ),
        ),
      ],
    );
  }
}

/// 점선 테두리 페인터
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.borderSubtle
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    // 위쪽 선
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // 오른쪽 선
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // 아래쪽 선
    startX = size.width;
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX - dashWidth, size.height),
        paint,
      );
      startX -= dashWidth + dashSpace;
    }

    // 왼쪽 선
    startY = size.height;
    while (startY > 0) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY - dashWidth),
        paint,
      );
      startY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

