import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

/// 검색 화면
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';

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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query.trim();
    });

    // TODO: 실제 검색 API 호출
    // 책, 노트, 인용구를 검색하는 로직 구현
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
      _isSearching = false;
      _searchQuery = '';
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: const Text(
          '검색',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
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
                  if (value.isEmpty) {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                    });
                  }
                },
                onSubmitted: _performSearch,
              ),
            ),
          ),
          // 검색 결과 또는 검색 제안
          Expanded(
            child: _isSearching
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
    // TODO: 실제 검색 결과 표시
    // 책, 노트, 인용구를 검색하여 결과 표시
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppTheme.metaLight,
          ),
          const SizedBox(height: 16),
          Text(
            '"$_searchQuery" 검색 결과',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '검색 기능은 준비 중입니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagData {
  final String name;
  final Color color;

  _TagData(this.name, this.color);
}
