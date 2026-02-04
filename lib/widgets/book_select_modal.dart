import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/book/book_providers.dart';
import '../models/book/book.dart';

// design.json: text #3d3d3d, #717182, border #e9e9e9
const _textPrimary = Color(0xFF3D3D3D);
const _textSecondary = Color(0xFF717182);
const _borderMedium = Color(0xFFE9E9E9);

/// 인용구/노트 작성 시 책을 선택하는 모달 (design.json 스타일)
class BookSelectModal extends ConsumerWidget {
  /// true: 인용구 쓰기, false: 노트 쓰기
  final bool isQuote;

  final ScrollController? scrollController;

  const BookSelectModal({
    super.key,
    required this.isQuote,
    this.scrollController,
  });

  static Future<void> show(BuildContext context, {required bool isQuote}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (_, scrollController) =>
              BookSelectModal(isQuote: isQuote, scrollController: scrollController),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = isQuote ? '어떤 책의 인용구인가요?' : '어떤 책의 노트인가요?';
    final subtitle = isQuote
        ? '인용구를 기록할 책을 선택해주세요'
        : '노트를 기록할 책을 선택해주세요';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: _textSecondary, size: 24),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _borderMedium),
          // 책 목록
          Flexible(
            child: ref.watch(myLibraryBooksProvider).when(
                  data: (books) {
                    if (books.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 48,
                              color: _textSecondary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '등록된 책이 없어요',
                              style: TextStyle(
                                fontSize: 16,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '아래 버튼에서 책을 추가해주세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _BookRow(
                          book: books[index],
                          onTap: () => _onBookSelected(
                            context,
                            ref,
                            books[index],
                            isQuote,
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        '책 목록을 불러올 수 없어요',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
          ),
          // + 다른 책 추가하기
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/book/add');
                },
                icon: const Icon(Icons.add, size: 20, color: _textPrimary),
                label: const Text(
                  '+ 다른 책 추가하기',
                  style: TextStyle(
                    fontSize: 15,
                    color: _textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textPrimary,
                  side: const BorderSide(color: _borderMedium),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

void _onBookSelected(
  BuildContext context,
  WidgetRef ref,
  Book book,
  bool isQuote,
) async {
  try {
    final bookDetail = await ref.read(bookDetailProvider(book.id).future);
    if (!context.mounted) return;
    Navigator.of(context).pop(); // close modal first
    if (isQuote) {
      context.push('/book/${book.id}/quote/create', extra: bookDetail);
    } else {
      context.push('/book/${book.id}/note/create', extra: bookDetail);
    }
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('책 정보를 불러올 수 없어요'),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookRow({
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderMedium, width: 1),
          ),
          child: Row(
            children: [
              // 표지
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 56,
                  height: 80,
                  color: AppTheme.borderSubtle,
                  child: book.coverImageUrl != null
                      ? Image.network(
                          book.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.menu_book,
                            color: _textSecondary,
                            size: 28,
                          ),
                        )
                      : const Icon(
                          Icons.menu_book,
                          color: _textSecondary,
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // 제목, 저자
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.menu_book_outlined,
                color: _textSecondary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
