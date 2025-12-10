import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth/auth_providers.dart';
import '../providers/book/book_providers.dart';
import '../data/mock_data.dart';

/// 프로필 화면
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final booksAsync = ref.watch(myLibraryBooksProvider);
    final stats = MockData.getProfileStats();
    final achievements = MockData.getAchievements();

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 카드
            _buildProfileCard(context, user, stats),
            const SizedBox(height: 24),
            // 나의 독서 기록
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 독서 기록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.headingDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  booksAsync.when(
                    data: (books) => _buildReadingStatsGrid(stats),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, __) => _buildReadingStatsGrid(stats),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 업적 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '업적',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.headingDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementsGrid(achievements),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 설정 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.headingDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsList(context, ref),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 프로필 카드
  Widget _buildProfileCard(
    BuildContext context,
    dynamic user,
    Map<String, dynamic> stats,
  ) {
    final startDate = stats['startDate'] as DateTime;
    final year = startDate.year;
    final month = startDate.month;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 아바타 (그라데이션 배경)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.brandBlue,
                  AppTheme.brandBlue.withOpacity(0.7),
                ],
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          // 닉네임
          Text(
            stats['nickname'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 8),
          // 상태 메시지
          Text(
            stats['statusMessage'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.bodyMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // 시작 날짜
          Text(
            '🗓️ $year년 $month월부터 함께',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.metaLight,
            ),
          ),
        ],
      ),
    );
  }

  /// 독서 통계 그리드
  Widget _buildReadingStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          icon: Icons.book,
          iconColor: const Color(0xFF3B82F6), // 파란색
          backgroundColor: const Color(0xFFEFF6FF),
          value: '${stats['booksRead']}',
          label: '읽은 책',
        ),
        _buildStatCard(
          icon: Icons.note,
          iconColor: const Color(0xFF10B981), // 초록색
          backgroundColor: const Color(0xFFECFDF5),
          value: '${stats['notesWritten']}',
          label: '작성한 노트',
        ),
        _buildStatCard(
          icon: Icons.format_quote,
          iconColor: const Color(0xFF8B5CF6), // 보라색
          backgroundColor: const Color(0xFFF5F3FF),
          value: '${stats['quotesSaved']}',
          label: '저장한 인용구',
        ),
        _buildStatCard(
          icon: Icons.calendar_today,
          iconColor: const Color(0xFFFF9800), // 주황색
          backgroundColor: const Color(0xFFFFF4E6),
          value: '${stats['readingDays']}일',
          label: '독서 일수',
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 업적 그리드
  Widget _buildAchievementsGrid(List<Map<String, dynamic>> achievements) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: achievements.map((achievement) {
        return _buildAchievementCard(achievement);
      }).toList(),
    );
  }

  /// 업적 카드
  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isCompleted = achievement['isCompleted'] as bool;
    final iconColor = achievement['iconColor'] as Color;
    final backgroundColor = achievement['backgroundColor'] as Color;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'] as IconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement['title'] as String,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.headingDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isCompleted) ...[
            const SizedBox(height: 4),
            const Icon(
              Icons.check_circle,
              color: Color(0xFF10B981),
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  /// 설정 리스트
  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFEFF6FF),
            title: '알림 설정',
            onTap: () {
              // TODO: 알림 설정 화면으로 이동
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            context,
            icon: Icons.palette_outlined,
            iconColor: const Color(0xFF10B981),
            backgroundColor: const Color(0xFFECFDF5),
            title: '테마 설정',
            onTap: () {
              // TODO: 테마 설정 화면으로 이동
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF8B5CF6),
            backgroundColor: const Color(0xFFF5F3FF),
            title: '개인정보 보호',
            onTap: () {
              // TODO: 개인정보 보호 화면으로 이동
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            context,
            icon: Icons.info_outline,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF4E6),
            title: '앱 정보',
            onTap: () {
              // TODO: 앱 정보 화면으로 이동
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            iconColor: const Color(0xFFEF4444),
            backgroundColor: const Color(0xFFFEF2F2),
            title: '로그아웃',
            onTap: () {
              _showLogoutDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  /// 설정 아이템
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.headingDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.metaLight,
            ),
          ],
        ),
      ),
    );
  }

  /// 구분선
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.borderSubtle,
      indent: 68,
    );
  }

  /// 로그아웃 다이얼로그
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                color: AppTheme.bodyMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authRepositoryProvider).logout();
              // 사용자 상태를 null로 설정하여 인증 상태 업데이트
              ref.read(currentUserProvider.notifier).state = null;
              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: AppTheme.brandBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
