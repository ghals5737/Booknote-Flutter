import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/statistics/statistics_providers.dart';
import '../models/statistics/statistics_response.dart';

/// 통계 화면
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            icon: const Icon(
              Icons.person_outline,
              color: AppTheme.headingDark,
            ),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: const _OverviewTab(),
    );
  }
}

/// 개요 탭
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(myStatisticsProvider);

    return statisticsAsync.when(
      data: (statistics) {
        final summary = statistics.summary;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 통계 카드 그리드
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildStatCard(
                    icon: Icons.book,
                    iconColor: AppTheme.brandBlue,
                    label: '전체',
                    value: summary.totalBooks.toString(),
                    description: '등록된 책',
                  ),
                  _buildStatCard(
                    icon: Icons.bookmark,
                    iconColor: const Color(0xFF10B981),
                    label: '읽은 책',
                    value: summary.readBooks.toString(),
                    description: '읽은 책',
                  ),
                  _buildStatCard(
                    icon: Icons.menu_book,
                    iconColor: const Color(0xFF8B5CF6),
                    label: '페이지',
                    value: summary.totalPages.toString(),
                    description: '읽은 페이지',
                  ),
                  _buildStatCard(
                    icon: Icons.note,
                    iconColor: const Color(0xFFFF9800),
                    label: '노트',
                    value: summary.totalNotes.toString(),
                    description: '작성한 노트',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 연속 독서 기록
              _buildReadingStreakCard(statistics.activity),
              const SizedBox(height: 16),
              // 월별 활동
              _buildMonthlyActivitySection(statistics.monthly),
              const SizedBox(height: 16),
              // 카테고리별 분포
              _buildCategoryDistributionSection(statistics.category),
              const SizedBox(height: 16),
              // 자주 사용하는 태그
              _buildFrequentTagsSection(statistics.tag),
              const SizedBox(height: 16),
              // 태그별 통계
              _buildTagStatsSection(statistics.tag),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러: $err')),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String description,
  }) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.metaLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStreakCard(Activity activity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFFC084FC),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '연속 독서 기록',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${activity.currentStreak}일',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (activity.maxStreak > activity.currentStreak)
                Text(
                  '최고 기록: ${activity.maxStreak}일',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
            ],
          ),
          Icon(
            Icons.local_fire_department,
            size: 48,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyActivitySection(List<MonthlyStat> monthlyStats) {
    if (monthlyStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            '월별 활동 데이터가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
        ),
      );
    }

    // 최근 6개월 데이터만 표시
    final recentMonths = monthlyStats.length > 6 
        ? monthlyStats.sublist(monthlyStats.length - 6)
        : monthlyStats;
    
    final maxReadCount = recentMonths.isNotEmpty
        ? recentMonths.map((m) => m.readCount).reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
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
          const Text(
            '월별 활동',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 16),
          // 월별 활동 차트
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: recentMonths.map((month) {
                final height = maxReadCount > 0 
                    ? (month.readCount / maxReadCount) * 100 
                    : 0.0;
                return _buildBarChart(month.label, height);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBarChart(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.brandBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.metaLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDistributionSection(List<CategoryStat> categoryStats) {
    if (categoryStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            '카테고리별 데이터가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
        ),
      );
    }

    final sortedCategories = List.from(categoryStats)
      ..sort((a, b) => b.count.compareTo(a.count));

    final maxCount = sortedCategories.isNotEmpty ? sortedCategories.first.count : 1;
    final categoryColors = [
      AppTheme.brandBlue,
      const Color(0xFF10B981),
      const Color(0xFFFFEB3B),
      const Color(0xFF8B5CF6),
      const Color(0xFFFF6B9D),
    ];

    return Container(
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
          const Text(
            '카테고리별 분포',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final percentage = (category.count / maxCount) * 100;
            final color = categoryColors[index % categoryColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: AppTheme.borderSubtle,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${category.count}권',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.headingDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.categoryName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.headingDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFrequentTagsSection(List<TagStat> tagStats) {
    if (tagStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            '태그 데이터가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
        ),
      );
    }

    // 사용 횟수 기준으로 정렬 후 상위 5개 태그만 표시
    final sortedTags = List<TagStat>.from(tagStats)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    final topTags = sortedTags.length > 5 
        ? sortedTags.sublist(0, 5)
        : sortedTags;

    final tagColors = [
      const Color(0xFFFF6B6B),
      AppTheme.brandBlue,
      const Color(0xFFFFEB3B),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
    ];

    return Container(
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
          const Text(
            '자주 사용하는 태그',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topTags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              final color = tagColors[index % tagColors.length];
              
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${tag.tagName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagStatsSection(List<TagStat> tagStats) {
    if (tagStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.divider,
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            '태그 통계 데이터가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
        ),
      );
    }

    // 사용 횟수 기준으로 정렬
    final sortedTags = List<TagStat>.from(tagStats)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));

    final maxCount = sortedTags.isNotEmpty ? sortedTags.first.usageCount : 1;
    final tagColors = [
      const Color(0xFFFF6B6B),
      AppTheme.brandBlue,
      const Color(0xFFFFEB3B),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
    ];

    return Container(
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
          const Text(
            '태그별 통계',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedTags.asMap().entries.map((entry) {
            final index = entry.key;
            final tag = entry.value;
            final percentage = (tag.usageCount / maxCount) * 100;
            final color = tagColors[index % tagColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // 순위
                  Text(
                    '#${index + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.metaLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 태그 이름
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${tag.tagName}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 진행 바
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppTheme.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.brandBlue),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 카운트
                  Text(
                    tag.usageCount.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.headingDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

