import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/review/review_item.dart';
import '../data/mock_data.dart';

/// 복습 관리 화면
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _currentIndex = 0; // 현재 복습 중인 항목 인덱스
  bool _isDetailMode = false; // 상세 모드 여부
  List<ReviewItem> _reviewItems = [];

  @override
  void initState() {
    super.initState();
    _loadReviewItems();
  }

  void _loadReviewItems() {
    setState(() {
      _reviewItems = MockReviewData.getReviewItems();
    });
  }


  void _completeReview() {
    // 복습 완료 처리
    if (_currentIndex < _reviewItems.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // 모든 복습 완료
      setState(() {
        _isDetailMode = false;
        _currentIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복습을 완료했습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _previousItem() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextItem() {
    if (_currentIndex < _reviewItems.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _exitDetailMode() {
    setState(() {
      _isDetailMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDetailMode && _reviewItems.isNotEmpty) {
      return _buildDetailView();
    }
    return _buildListView();
  }

  /// 목록 뷰
  Widget _buildListView() {
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
            icon: Icon(
              Icons.view_module,
              color: AppTheme.metaLight,
            ),
            onPressed: () {
              // 보기 모드 변경 (현재는 미구현)
            },
          ),
          IconButton(
            icon: Icon(
              Icons.list,
              color: AppTheme.metaLight,
            ),
            onPressed: () {
              // 필터/정렬 (현재는 미구현)
            },
          ),
        ],
      ),
      
      body: _reviewItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 64,
                    color: AppTheme.metaLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '복습할 항목이 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reviewItems.length,
              itemBuilder: (context, index) {
                final item = _reviewItems[index];
                return _buildReviewCard(item, index);
              },
            ),
    );
  }

  /// 복습 카드
  Widget _buildReviewCard(ReviewItem item, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _isDetailMode = true;
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
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
            // 우선순위 태그와 복습 횟수
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriorityTag(item.priority),
                Text(
                  '복습 ${item.reviewCount}회',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.metaLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 카테고리
            Text(
              item.category,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.metaLight,
              ),
            ),
            const SizedBox(height: 8),
            // 제목
            Text(
              item.isNote ? item.title : item.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.headingDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 내용 (노트인 경우)
            if (item.isNote && item.content.isNotEmpty)
              Text(
                item.content,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.bodyMedium,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            // 인용구 아이콘 (인용구인 경우)
            if (!item.isNote)
              Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 16,
                    color: AppTheme.brandBlue,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.bodyMedium,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            // 마지막 복습 날짜
            Text(
              '마지막 복습: ${_formatDate(item.lastReviewDate)}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.metaLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 우선순위 태그
  Widget _buildPriorityTag(String priority) {
    Color backgroundColor;
    Color textColor;

    switch (priority) {
      case '높음':
        backgroundColor = const Color(0xFFFF6B6B);
        textColor = Colors.white;
        break;
      case '보통':
        backgroundColor = const Color(0xFF51CF66);
        textColor = Colors.white;
        break;
      default:
        backgroundColor = AppTheme.borderSubtle;
        textColor = AppTheme.bodyMedium;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '우선순위: $priority',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// 상세 뷰
  Widget _buildDetailView() {
    if (_reviewItems.isEmpty) return const SizedBox.shrink();

    final item = _reviewItems[_currentIndex];
    final totalItems = _reviewItems.length;
    final currentNumber = _currentIndex + 1;
    final progress = (currentNumber / totalItems) * 100;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _exitDetailMode,
        ),
        title: const Text(
          '복습',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.view_module,
              color: AppTheme.metaLight,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.list,
              color: AppTheme.metaLight,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 표시
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceWhite,
            child: Row(
              children: [
                Text(
                  '$currentNumber/$totalItems',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.headingDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: AppTheme.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brandBlue),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${progress.toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.headingDark,
                  ),
                ),
              ],
            ),
          ),
          // 메인 카드
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 우선순위 태그
                    _buildPriorityTag(item.priority),
                    const SizedBox(height: 16),
                    // 복습 횟수
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '복습 ${item.reviewCount}회',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.metaLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 아이콘 (노트 또는 인용구)
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: item.isNote
                              ? AppTheme.brandLightTint
                              : const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          item.isNote ? Icons.note : Icons.format_quote,
                          size: 40,
                          color: item.isNote
                              ? AppTheme.brandBlue
                              : const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 책 제목
                    Center(
                      child: Text(
                        item.bookTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.metaLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 제목 (노트) 또는 인용구 텍스트
                    Center(
                      child: Text(
                        item.isNote ? item.title : item.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.headingDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 내용 (노트인 경우)
                    if (item.isNote && item.content.isNotEmpty)
                      Center(
                        child: Text(
                          item.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.bodyMedium,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // 탭하여 내용 보기
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '탭하여 내용 보기',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.metaLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.metaLight,
                          ),
                        ],
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
              child: Row(
                children: [
                  // 이전 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex > 0 ? _previousItem : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _currentIndex > 0
                              ? AppTheme.borderSubtle
                              : AppTheme.divider,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: _currentIndex > 0
                                ? AppTheme.bodyMedium
                                : AppTheme.metaLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '이전',
                            style: TextStyle(
                              fontSize: 14,
                              color: _currentIndex > 0
                                  ? AppTheme.bodyMedium
                                  : AppTheme.metaLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 완료 버튼
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _completeReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '완료',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 다음 버튼
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentIndex < _reviewItems.length - 1
                          ? _nextItem
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _currentIndex < _reviewItems.length - 1
                              ? AppTheme.borderSubtle
                              : AppTheme.divider,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '다음',
                            style: TextStyle(
                              fontSize: 14,
                              color: _currentIndex < _reviewItems.length - 1
                                  ? AppTheme.bodyMedium
                                  : AppTheme.metaLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: _currentIndex < _reviewItems.length - 1
                                ? AppTheme.bodyMedium
                                : AppTheme.metaLight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
