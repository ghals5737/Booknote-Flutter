import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

/// design.json 기반 BookStatusCard 스타일
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 1),
        boxShadow: [AppTheme.statusCardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 책 표지
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 120,
                    color: AppTheme.borderSubtle,
                    child: book.coverImageUrl != null
                        ? Image.network(
                            book.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.book,
                                size: 40,
                                color: AppTheme.metaLight,
                              );
                            },
                          )
                        : const Icon(
                            Icons.book,
                            size: 40,
                            color: AppTheme.metaLight,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // 책 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 제목
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.headingDark,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 저자
                      Text(
                        book.author,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 진행률 정보
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 진행률 퍼센트
                          Text(
                            '${book.progress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brandBlue,
                            ),
                          ),
                          // 페이지 정보
                          Text(
                            '${book.currentPage}/${book.totalPages}p',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 진행률 바 (design.json: height 6px, borderRadius 4px)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: book.progress / 100,
                          minHeight: 6,
                          backgroundColor: AppTheme.borderSubtle,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.brandBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 노트 수 (오른쪽 정렬)
                if (book.noteCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${book.noteCount}개',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.brandBlue,
                          ),
                        ),
                        const Text(
                          '노트',
                          style: TextStyle(
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
      ),
    );
  }
}

