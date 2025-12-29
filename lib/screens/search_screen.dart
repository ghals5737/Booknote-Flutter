import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/search/search_providers.dart';
import '../models/search/unified_search_response.dart';

/// 검색 화면
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  String _debouncedQuery = '';

  // 최근 검색어 (실제로는 SharedPreferences나 서버에서 가져와야 함)
  final List<String> _recentSearches = ['습관', '코드', '성장', '독서'];

  // 인기 태그
  final List<_TagData> _popularTags = [
    _TagData('중요', AppTheme.brandBlue),
    _TagData('복습', AppTheme.brandBlue),
    _TagData('질문', AppTheme.brandBlue),
    _TagData('인용', AppTheme.brandBlue),
    _TagData('아이디어', AppTheme.brandBlue),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Debounce 처리 (300ms)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _debouncedQuery = query;
        });
      }
    });
  }

  void _performSearch(String query) {
    _searchController.text = query;
    setState(() {
      _debouncedQuery = query.trim();
    });
  }

  void _selectRecentSearch(String searchTerm) {
    _searchController.text = searchTerm;
    _performSearch(searchTerm);
  }

  void _selectTag(String tag) {
    _searchController.text = '#$tag';
    _performSearch('#$tag');
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _debouncedQuery = '';
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '책, 노트, 인용구 검색...',
                  hintStyle: TextStyle(
                    color: AppTheme.placeholder,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.metaLight,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.metaLight,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
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
                },
                onSubmitted: _performSearch,
              ),
            ),
          ),
          // 검색 결과 또는 검색 제안
          Expanded(
            child: _debouncedQuery.length >= 2
                ? _buildSearchResults()
                : _buildSearchSuggestions(),
          ),
        ],
      ),
    );
  }

  /// 검색 제안 (최근 검색어, 인기 태그)
  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최근 검색어
          if (_recentSearches.isNotEmpty) ...[
            const Text(
              '최근 검색어',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.headingDark,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((search) {
                return GestureDetector(
                  onTap: () => _selectRecentSearch(search),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      search,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          // 인기 태그
          const Text(
            '인기 태그',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularTags.map((tag) {
              return GestureDetector(
                onTap: () => _selectTag(tag.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: tag.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#${tag.name}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tag.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 검색 결과
  Widget _buildSearchResults() {
    final searchParams = UnifiedSearchParams(
      query: _debouncedQuery,
      type: 'all',
      page: 1,
      size: 10,
    );

    final searchAsync = ref.watch(unifiedSearchProvider(searchParams));

    return searchAsync.when(
      data: (data) {
        final hasResults = data.books.isNotEmpty ||
            data.notes.isNotEmpty ||
            data.quotes.isNotEmpty;

        if (!hasResults) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.metaLight,
                ),
                const SizedBox(height: 16),
                Text(
                  '검색 결과가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_debouncedQuery"에 대한 결과를 찾을 수 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.metaLight,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 검색 결과
              if (data.books.isNotEmpty) ...[
                _buildSectionHeader('책', data.books.length),
                const SizedBox(height: 12),
                ...data.books.map((book) => _buildBookItem(book)),
                const SizedBox(height: 24),
              ],
              // 노트 검색 결과
              if (data.notes.isNotEmpty) ...[
                _buildSectionHeader('노트', data.notes.length),
                const SizedBox(height: 12),
                ...data.notes.map((note) => _buildNoteItem(note)),
                const SizedBox(height: 24),
              ],
              // 인용구 검색 결과
              if (data.quotes.isNotEmpty) ...[
                _buildSectionHeader('인용구', data.quotes.length),
                const SizedBox(height: 12),
                ...data.quotes.map((quote) => _buildQuoteItem(quote)),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.metaLight,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 중 오류가 발생했습니다',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.metaLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.metaLight,
          ),
        ),
      ],
    );
  }

  Widget _buildBookItem(UnifiedBookItem book) {
    return InkWell(
      onTap: () {
        context.push('/book/${book.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.brandBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.book,
                color: AppTheme.brandBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.headingDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.author != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      book.author!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.bodyMedium,
                      ),
                    ),
                  ],
                  if (book.notesCount != null || book.quotesCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (book.notesCount != null) '노트 ${book.notesCount}개',
                        if (book.quotesCount != null) '인용구 ${book.quotesCount}개',
                      ].join(' · '),
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
    );
  }

  Widget _buildNoteItem(UnifiedNoteItem note) {
    return InkWell(
      onTap: () {
        context.push('/book/${note.bookId}/note/${note.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  size: 20,
                  color: AppTheme.brandBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.headingDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.bookTitle ?? '알 수 없음',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.bodyMedium,
              ),
            ),
            if (note.snippet != null && note.snippet!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.snippet!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.bodyMedium,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteItem(UnifiedQuoteItem quote) {
    final metaParts = <String>[];
    if (quote.page != null) metaParts.add('p.${quote.page}');
    if (quote.chapter != null) metaParts.add(quote.chapter!);

    return InkWell(
      onTap: () {
        context.push('/book/${quote.bookId}/quote/${quote.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote,
                  size: 20,
                  color: AppTheme.brandBlue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quote.bookTitle ?? '알 수 없음',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quote.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.headingDark,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (metaParts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                metaParts.join(' · '),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagData {
  final String name;
  final Color color;

  _TagData(this.name, this.color);
}
