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
              _buildReadingStreakCard(),
              const SizedBox(height: 16),
              // 월별 활동
              _buildMonthlyActivitySection(statistics.monthly),
              const SizedBox(height: 16),
              // 카테고리별 분포
              _buildCategoryDistributionSection(statistics.category),
              const SizedBox(height: 16),
              // 자주 사용하는 태그
              _buildFrequentTagsSection(),
              const SizedBox(height: 16),
              // 태그별 통계
              _buildTagStatsSection(),
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

  Widget _buildReadingStreakCard() {
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
              const Text(
                '15일',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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

  Widget _buildFrequentTagsSection() {
    // Mock 태그 데이터
    final frequentTags = [
      _TagData('중요', const Color(0xFFFF6B6B)),
      _TagData('복습', AppTheme.brandBlue),
      _TagData('질문', const Color(0xFFFFEB3B)),
      _TagData('인용', const Color(0xFF10B981)),
      _TagData('아이디어', const Color(0xFF8B5CF6)),
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
            children: frequentTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tag.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${tag.name}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tag.color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagStatsSection() {
    // Mock 태그 통계 데이터
    final tagStats = [
      _TagStat('중요', 25, const Color(0xFFFF6B6B)),
      _TagStat('복습', 18, AppTheme.brandBlue),
      _TagStat('질문', 15, const Color(0xFFFFEB3B)),
      _TagStat('인용', 12, const Color(0xFF10B981)),
      _TagStat('아이디어', 10, const Color(0xFF8B5CF6)),
    ];

    final maxCount = tagStats.isNotEmpty ? tagStats.first.count : 1;

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
          ...tagStats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            final percentage = (stat.count / maxCount) * 100;

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
                      color: stat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${stat.name}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: stat.color,
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
                    stat.count.toString(),
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

class _TagData {
  final String name;
  final Color color;

  _TagData(this.name, this.color);
}

class _TagStat {
  final String name;
  final int count;
  final Color color;

  _TagStat(this.name, this.count, this.color);
}
