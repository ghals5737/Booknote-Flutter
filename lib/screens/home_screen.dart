import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/review/review_providers.dart';
import '../providers/book/book_providers.dart';
import '../providers/quote/quote_providers.dart';
import '../models/book/book.dart';

/// 홈 화면 - 오늘의 복습 미리보기, 최근 읽은 책, 오늘의 인용구
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // 인사말
              _buildGreeting(),
              const SizedBox(height: 24),
              // 오늘의 복습 미리보기
              _buildTodayReviewPreview(context, ref),
              const SizedBox(height: 24),
              // 최근 읽은 책
              _buildRecentBooks(context, ref),
              const SizedBox(height: 24),
              // 오늘의 인용구
              _buildDailyQuote(context, ref),
              const SizedBox(height: 96), // 하단 네비게이션 공간
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF5D4A3A), // design.json primary brown
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
              fontSize: 18,
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
            Icons.notifications_outlined,
            color: AppTheme.headingDark,
          ),
          onPressed: () {
            // 알림 화면으로 이동
          },
        ),
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
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (hour < 18) {
      greeting = '좋은 오후에요';
    } else {
      greeting = '좋은 저녁이에요';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.headingDark,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.wb_cloudy_outlined,
              size: 20,
              color: AppTheme.metaLight,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '오늘은 어떤 책을 읽으실 건가요?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayReviewPreview(BuildContext context, WidgetRef ref) {
    final todayReviewAsync = ref.watch(todayReviewProvider);

    return todayReviewAsync.when(
      data: (reviewData) {
        final incompleteItems = reviewData.items.where((item) => !item.completed).toList();
        final totalCount = incompleteItems.length;

        if (totalCount == 0) {
          // 완료 시 축하 메시지
          return _buildCompletionCard();
        }

        // 첫 번째 복습 항목만 미리보기
        final firstItem = incompleteItems.first;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF5D4A3A).withOpacity(0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘의 복습',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '기억을 다시 만날 시간이에요',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  // 아이콘 컨테이너
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5D4A3A), Color(0xFF4D3A2A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.format_quote,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 미리보기 내용
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.format_quote,
                            color: Color(0xFF5D4A3A),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            firstItem.itemType == 'NOTE'
                                ? (firstItem.note?.title ?? '')
                                : (firstItem.quote?.text ?? ''),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.headingDark,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '📖 ${firstItem.bookTitle}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.metaLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // CTA 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/review');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D4A3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    '복습하러 가기 ($totalCount개) →',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.divider),
        ),
        child: const Text(
          '복습 데이터를 불러올 수 없습니다',
          style: TextStyle(color: AppTheme.bodyMedium),
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F8F8), Color(0xFFF0F0F0)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF5D4A3A).withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            size: 48,
            color: Color(0xFF5D4A3A),
          ),
          const SizedBox(height: 16),
          const Text(
            '🎉 오늘의 복습을 모두 완료했어요!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '내일 다시 만나요',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBooks(BuildContext context, WidgetRef ref) {
    final recentBooksAsync = ref.watch(recentReadBooksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '최근 읽은 책',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.headingDark,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/library');
              },
              child: const Text(
                '더보기',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recentBooksAsync.when(
          data: (books) {
            if (books.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '최근 읽은 책이 없습니다',
                    style: TextStyle(
                      color: AppTheme.bodyMedium,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            // 최대 3권만 표시
            final displayBooks = books.take(3).toList();

            return SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayBooks.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildBookCard(context, displayBooks[index]);
                },
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              '에러: $err',
              style: const TextStyle(color: AppTheme.bodyMedium),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        context.push('/book/${book.id}', extra: book);
      },
      child: Container(
        width: 128,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 표지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 128,
                height: 170,
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
            const SizedBox(height: 8),
            // 제목
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.headingDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // 저자
            Text(
              book.author,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.metaLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 진행률 바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: book.progress / 100,
                minHeight: 4,
                backgroundColor: AppTheme.borderSubtle,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF5D4A3A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuote(BuildContext context, WidgetRef ref) {
    // TODO: 오늘의 인용구 API가 있으면 사용, 없으면 최근 인용구 중 하나 표시
    // 일단은 최근 읽은 책의 인용구를 가져오는 방식으로 구현
    final recentBooksAsync = ref.watch(recentReadBooksProvider);

    return recentBooksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return const SizedBox.shrink();
        }

        // 첫 번째 책의 인용구를 가져옴
        final firstBook = books.first;
        final quotesAsync = ref.watch(quotesForBookProvider(firstBook.id));

        return quotesAsync.when(
          data: (quotes) {
            if (quotes.isEmpty) {
              return const SizedBox.shrink();
            }

            // 첫 번째 인용구 사용
            final quote = quotes.first;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 인용구',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.headingDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.rotate(
                        angle: 3.14159, // 180도 회전
                        child: const Icon(
                          Icons.format_quote,
                          size: 24,
                          color: AppTheme.metaLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quote.text,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.headingDark,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.format_quote,
                        size: 24,
                        color: AppTheme.metaLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '- ${firstBook.title} · ${firstBook.author}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
