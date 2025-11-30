import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quote/quote.dart';
import '../theme/app_theme.dart';
import '../providers/book/book_providers.dart';
import '../providers/quote/quote_providers.dart';

class QuoteDetailScreen extends ConsumerStatefulWidget {
  final Quote quote;
  final int bookId;

  const QuoteDetailScreen({
    super.key,
    required this.quote,
    required this.bookId,
  });

  @override
  ConsumerState<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends ConsumerState<QuoteDetailScreen> {
  bool _showMenu = false;
  bool _isDeleting = false;
  final GlobalKey _moreButtonKey = GlobalKey();

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}Z';
  }

  void _showActionMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  Future<void> _deleteQuote() async {
    setState(() {
      _showMenu = false;
    });
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인용구 삭제'),
        content: const Text('이 인용구를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true && mounted) {
      setState(() {
        _isDeleting = true;
      });
      
      try {
        final quoteService = ref.read(quoteServiceProvider);
        await quoteService.deleteQuote(widget.quote.id);
        
        if (mounted) {
          // Provider 무효화하여 리스트 새로고침
          ref.invalidate(quotesForBookProvider(widget.bookId));
          ref.invalidate(bookFullDataProvider(widget.bookId));
          
          // 이전 화면으로 돌아가기
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인용구가 삭제되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('인용구 삭제 실패: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookDetailAsync = ref.watch(bookDetailProvider(widget.bookId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // 인용구 카드
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 중요 인용구 헤더 (isImportant가 true일 때만 표시)
                      if (widget.quote.isImportant)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFB800), // 금색/노란색
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '중요 인용구',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD97706), // 갈색/주황색
                              ),
                            ),
                            const Spacer(),
                            // 더보기 버튼
                            IconButton(
                              key: _moreButtonKey,
                              icon: const Icon(Icons.more_vert),
                              color: AppTheme.bodyMedium,
                              onPressed: _showActionMenu,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ),
                      if (widget.quote.isImportant) const SizedBox(height: 16),
                      // 인용구 내용
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽 따옴표 아이콘 (ri-double-quotes-l) - 회전시켜서 표시
                          Transform.rotate(
                            angle: 3.14159, // 180도 회전 (π radians)
                            child: Icon(
                              Icons.format_quote,
                              size: 24, // text-2xl (24px)
                              color: Colors.grey[400], // text-gray-400
                            ),
                          ),
                          const SizedBox(width: 8), // mr-2 (8px)
                          // 인용구 텍스트
                          Expanded(
                            child: Text(
                              widget.quote.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.headingDark,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // ml-2 (8px)
                          // 오른쪽 따옴표 아이콘 (ri-double-quotes-r)
                          Icon(
                            Icons.format_quote,
                            size: 24, // text-2xl (24px)
                            color: Colors.grey[400], // text-gray-400
                          ),
                          // 더보기 버튼 (isImportant가 false일 때만 표시)
                          if (!widget.quote.isImportant) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              key: _moreButtonKey,
                              icon: const Icon(Icons.more_vert),
                              color: AppTheme.bodyMedium,
                              onPressed: _showActionMenu,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ],
                      ),
                  const SizedBox(height: 16),
                  // 메타데이터
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.book,
                            size: 16,
                            color: AppTheme.metaLight,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: bookDetailAsync.when(
                              data: (bookDetail) => Text(
                                bookDetail.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.metaLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              loading: () => const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              error: (_, __) => const Text(
                                '책 정보 없음',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.metaLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.description,
                            size: 16,
                            color: AppTheme.metaLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'p.${widget.quote.page}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.metaLight,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.metaLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDateTime(widget.quote.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.metaLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // 메모 (comment)가 있는 경우
                  if (widget.quote.comment != null && widget.quote.comment!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.borderSubtle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.quote.comment!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // 태그
                  if (widget.quote.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.quote.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.borderSubtle,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.bodyMedium,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 이 인용구가 속한 책
            bookDetailAsync.when(
              data: (bookDetail) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '이 인용구가 속한 책',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.headingDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // 책 커버
                        Container(
                          width: 60,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.borderSubtle,
                              width: 1,
                            ),
                            color: AppTheme.borderSubtle,
                          ),
                          child: bookDetail.coverImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(
                                    bookDetail.coverImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.book,
                                        size: 30,
                                        color: AppTheme.metaLight,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.book,
                                  size: 30,
                                  color: AppTheme.metaLight,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // 책 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookDetail.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.headingDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bookDetail.author,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 책 상세보기 버튼
                        TextButton(
                          onPressed: () {
                            context.go('/book/${widget.bookId}');
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '책 상세보기',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.brandBlue,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: AppTheme.brandBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                child: Text('책 정보를 불러올 수 없습니다: $err'),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
          // 배경 오버레이 (메뉴가 열릴 때)
          if (_showMenu)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _showMenu = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          // 더보기 메뉴
          if (_showMenu)
            Builder(
              builder: (context) {
                // 더보기 버튼의 위치 계산
                final RenderBox? renderBox = _moreButtonKey.currentContext?.findRenderObject() as RenderBox?;
                final Offset? offset = renderBox?.localToGlobal(Offset.zero);
                final Size? size = renderBox?.size;
                
                // 위치 계산 (더보기 버튼 아래에 배치)
                double top = 100; // 기본값
                double right = 16; // 기본값
                
                if (offset != null && size != null) {
                  // 더보기 버튼의 오른쪽 아래에 메뉴 배치
                  top = offset.dy + size.height;
                  right = MediaQuery.of(context).size.width - offset.dx - size.width;
                }
                
                return Positioned(
                  right: right,
                  top: top,
                  child: IgnorePointer(
                    ignoring: false,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.divider,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              title: const Text(
                                '삭제',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                              onTap: () {
                                _deleteQuote();
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

