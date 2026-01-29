import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth/auth_providers.dart';
import '../providers/review/review_providers.dart';
import '../providers/home/recent_activity_provider.dart';
import '../models/book/book.dart';

// design.json: primary brown #5d4a3a, grayLight #f8f8f8, grayMedium #f3f3f5, text #3d3d3d / #717182
const _primaryBrown = Color(0xFF5D4A3A);
const _grayLight = Color(0xFFF8F8F8);
const _grayMedium = Color(0xFFF3F3F5);
const _textPrimary = Color(0xFF3D3D3D);
const _textSecondary = Color(0xFF717182);

/// 홈 화면 - design.json + 이미지 레이아웃: 인사말, 액션 카드, 오늘의 복습, 최근 활동
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
              _buildGreeting(ref),
              const SizedBox(height: 24),
              _buildActionCards(context),
              const SizedBox(height: 20),
              _buildTodayReviewCard(context, ref),
              const SizedBox(height: 24),
              _buildRecentActivity(context, ref),
              const SizedBox(height: 96),
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
              color: _primaryBrown,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            'Booknote',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: _textPrimary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: AppTheme.surfaceWhite,
      elevation: 0,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: _grayMedium,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: _textSecondary, size: 20),
          ),
          onPressed: () => context.push('/profile'),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: _grayMedium,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: _textSecondary, size: 20),
          ),
          onPressed: () {
            // 메뉴 (필요 시 드로어/바텀시트)
          },
        ),
      ],
    );
  }

  Widget _buildGreeting(WidgetRef ref) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = '좋은 아침이에요';
    else if (hour < 18) greeting = '좋은 오후에요';
    else greeting = '좋은 저녁이에요';

    final user = ref.watch(currentUserProvider);
    final name = (user?.name ?? '').trim().isEmpty ? '회원' : (user!.name.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${name}님',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '오늘은 어떤 책을 읽으실 건가요?',
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            context,
            icon: Icons.format_quote,
            title: '인용구 쓰기',
            subtitle: '최애책 인상 깊은 문장',
            onTap: () => context.push('/library'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            context,
            icon: Icons.note_add_outlined,
            title: '노트 쓰기',
            subtitle: '나의 생각과 느낌 기록',
            onTap: () => context.push('/library'),
          ),
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _grayMedium,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _primaryBrown.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _primaryBrown, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayReviewCard(BuildContext context, WidgetRef ref) {
    final todayReviewAsync = ref.watch(todayReviewProvider);

    return todayReviewAsync.when(
      data: (reviewData) {
        final incomplete = reviewData.items.where((e) => !e.completed).toList();
        final count = incomplete.length;

        if (count == 0) {
          return _completionCard();
        }

        return Material(
          color: const Color(0xFFF5F0E8), // light brown/beige
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => context.push('/review'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primaryBrown.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark, color: _primaryBrown, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '오늘의 복습',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _primaryBrown,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '오늘 복습할 기억이 $count개 있어요',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '과거의 기억을 다시 돌아보며 기억을 강화해보세요',
                          style: TextStyle(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: _textSecondary),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _completionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _grayLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryBrown.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration, color: _primaryBrown, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '오늘의 복습을 모두 완료했어요!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 활동',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        activityAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: const Text(
                    '아직 활동이 없어요',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textSecondary,
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _activityItem(context, item);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '활동을 불러올 수 없어요',
                style: const TextStyle(fontSize: 14, color: _textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _activityItem(BuildContext context, RecentActivityItem item) {
    final displayText = item.text.length > 20 ? '${item.text.substring(0, 20)}…' : item.text;
    final timeAgo = _timeAgo(item.createdAt);
    final typeLabel = item.isQuote ? '인용구' : '노트';

    return Material(
      color: _grayMedium,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.push(
            '/book/${item.bookId}',
            extra: Book(
              id: item.bookId,
              title: item.bookTitle,
              author: '',
              category: '',
              totalPages: 0,
              currentPage: 0,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _primaryBrown.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.format_quote, color: _primaryBrown, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$displayText (${item.bookTitle})',
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
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금 전';
  }
}
