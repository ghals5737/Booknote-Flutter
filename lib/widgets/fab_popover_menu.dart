import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../screens/add_book_screen.dart';
import '../screens/create_note_screen.dart';
import '../screens/create_quote_screen.dart';
import '../models/book/book_detail_response.dart';
import '../models/book/book.dart';
import '../providers/book/book_providers.dart';

/// FAB 팝오버 메뉴
class FABPopoverMenu extends ConsumerWidget {
  final VoidCallback onDismiss;

  const FABPopoverMenu({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // 메뉴 내부 탭은 이벤트 전파 방지
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 메뉴 컨테이너
          Container(
            width: 280,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 책 추가
                _buildMenuItem(
                  context: context,
                  icon: Icons.book,
                  iconColor: AppTheme.brandBlue,
                  title: '책 추가',
                  subtitle: '새로운 책을 서재에 추가',
                  onTap: () {
                    onDismiss();
                    _showAddBookModal(context);
                  },
                ),
                const Divider(height: 1, color: AppTheme.divider),
                // 노트 추가
                _buildMenuItem(
                  context: context,
                  icon: Icons.note_add,
                  iconColor: const Color(0xFF10B981), // Green
                  title: '노트 추가',
                  subtitle: '독서 노트 작성',
                  onTap: () {
                    onDismiss();
                    _showBookSelectionModal(context, ref, isNote: true);
                  },
                ),
                const Divider(height: 1, color: AppTheme.divider),
                // 인용구 추가
                _buildMenuItem(
                  context: context,
                  icon: Icons.format_quote,
                  iconColor: const Color(0xFF8B5CF6), // Purple
                  title: '인용구 추가',
                  subtitle: '마음에 드는 구절 저장',
                  onTap: () {
                    onDismiss();
                    _showBookSelectionModal(context, ref, isNote: false);
                  },
                ),
              ],
            ),
          ),
          // 아래쪽 화살표
          Positioned(
            bottom: -8,
            left: (280 - 20) / 2,
            child: CustomPaint(
              size: const Size(20, 10),
              painter: _ArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.headingDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.metaLight,
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

/// 아래쪽 화살표 페인터
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.surfaceWhite
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 책 추가 모달 표시
void _showAddBookModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProviderScope(
          parent: ProviderScope.containerOf(context, listen: false),
          child: const AddBookScreen(),
        ),
      ),
    ),
  );
}

/// 노트 추가 모달 표시
void showCreateNoteModal(BuildContext context, BookDetailData bookDetail) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProviderScope(
          parent: ProviderScope.containerOf(context, listen: false),
          child: CreateNoteScreen(bookDetail: bookDetail),
        ),
      ),
    ),
  );
}

/// 인용구 추가 모달 표시
void showCreateQuoteModal(BuildContext context, BookDetailData bookDetail) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProviderScope(
          parent: ProviderScope.containerOf(context, listen: false),
          child: CreateQuoteScreen(bookDetail: bookDetail),
        ),
      ),
    ),
  );
}

/// 책 선택 모달 표시 (노트/인용구 추가용)
void _showBookSelectionModal(BuildContext context, WidgetRef ref, {required bool isNote}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ProviderScope(
          parent: ProviderScope.containerOf(context, listen: false),
          child: _BookSelectionModal(
            isNote: isNote,
            scrollController: scrollController,
          ),
        ),
      ),
    ),
  );
}

/// 책 선택 모달 위젯
class _BookSelectionModal extends ConsumerWidget {
  final bool isNote;
  final ScrollController scrollController;

  const _BookSelectionModal({
    required this.isNote,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(myLibraryBooksProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.metaLight,
                    ),
                  ),
                ),
                Text(
                  isNote ? '노트를 추가할 책 선택' : '인용구를 추가할 책 선택',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.headingDark,
                  ),
                ),
                const SizedBox(width: 60), // 취소 버튼과 균형 맞추기
              ],
            ),
          ),
          // 책 목록
          Expanded(
            child: booksAsync.when(
              data: (books) {
                if (books.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: AppTheme.metaLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '서재에 책이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '먼저 책을 추가해주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.metaLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return InkWell(
                      onTap: () async {
                        Navigator.of(context).pop(); // 책 선택 모달 닫기
                        
                        // 책 상세 정보 가져오기
                        try {
                          final bookDetail = await ref.read(bookDetailProvider(book.id).future);
                          
                          if (context.mounted) {
                            if (isNote) {
                              showCreateNoteModal(context, bookDetail);
                            } else {
                              showCreateQuoteModal(context, bookDetail);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('책 정보를 불러오는데 실패했습니다: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
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
                        child: Row(
                          children: [
                            // 책 커버
                            Container(
                              width: 50,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.borderSubtle,
                                  width: 1,
                                ),
                                color: AppTheme.borderSubtle,
                              ),
                              child: book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        book.coverImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.book,
                                            size: 24,
                                            color: AppTheme.metaLight,
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.book,
                                      size: 24,
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
                                    book.title,
                                    style: const TextStyle(
                                      fontSize: 16,
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
                                      fontSize: 14,
                                      color: AppTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppTheme.metaLight,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
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
                      '책 목록을 불러오는데 실패했습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ref.refresh(myLibraryBooksProvider);
                      },
                      child: const Text('재시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

