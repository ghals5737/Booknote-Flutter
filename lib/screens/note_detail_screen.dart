import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/note/note.dart';
import '../theme/app_theme.dart';
import '../providers/book/book_providers.dart';
import '../providers/note/note_providers.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note note;
  final int bookId;

  const NoteDetailScreen({
    super.key,
    required this.note,
    required this.bookId,
  });

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
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


  Future<void> _deleteNote() async {
    setState(() {
      _showMenu = false;
    });
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('노트 삭제'),
        content: const Text('이 노트를 삭제하시겠습니까?'),
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
        final noteService = ref.read(noteServiceProvider);
        await noteService.deleteNote(widget.note.id);
        
        if (mounted) {
          // Provider 무효화하여 리스트 새로고침
          ref.invalidate(notesForBookProvider(widget.bookId));
          ref.invalidate(bookFullDataProvider(widget.bookId));
          
          // 이전 화면으로 돌아가기
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('노트가 삭제되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('노트 삭제 실패: ${e.toString()}'),
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
                // 노트 카드
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
                      // 제목과 더보기 버튼
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.note.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.headingDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                            'p.${widget.note.page}',
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
                            _formatDateTime(widget.note.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.metaLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 내용
                  Text(
                    widget.note.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.headingDark,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 태그
                  if (widget.note.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.note.tags.map((tag) {
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
            // 이 노트가 속한 책
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
                      '이 노트가 속한 책',
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
                                Icons.edit,
                                size: 20,
                                color: AppTheme.bodyMedium,
                              ),
                              title: const Text(
                                '수정',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.headingDark,
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  _showMenu = false;
                                });
                                
                                final bookDetailAsync = ref.read(bookDetailProvider(widget.bookId));
                                final bookDetail = bookDetailAsync.when(
                                  data: (data) => data,
                                  loading: () => null,
                                  error: (_, __) => null,
                                );
                                
                                if (bookDetail != null && mounted) {
                                  final result = await context.push(
                                    '/book/${widget.bookId}/note/${widget.note.id}/edit',
                                    extra: {'note': widget.note, 'bookDetail': bookDetail},
                                  );
                                  
                                  // 수정 성공 시 Provider 무효화하여 데이터 새로고침
                                  if (result == true && mounted) {
                                    ref.invalidate(notesForBookProvider(widget.bookId));
                                    ref.invalidate(bookFullDataProvider(widget.bookId));
                                    // 노트 상세 화면도 새로고침하기 위해 다시 로드
                                    Navigator.of(context).pop();
                                    context.push(
                                      '/book/${widget.bookId}/note/${widget.note.id}',
                                      extra: widget.note,
                                    );
                                  }
                                }
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            ),
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
                                _deleteNote();
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

