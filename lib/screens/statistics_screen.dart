import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/book/book_providers.dart';

/// 통계 화면
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
         bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandBlue,
          indicatorWeight: 2,
          labelColor: AppTheme.headingDark,
          unselectedLabelColor: AppTheme.metaLight,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: '개요'),
            Tab(text: '활동'),
            Tab(text: '태그'),
          ],
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _ActivityTab(),
          _TagsTab(),
        ],
      ),
    );
  }
}

/// 개요 탭
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(myLibraryBooksProvider);

    return booksAsync.when(
      data: (books) {
        // 통계 계산
        final totalBooks = books.length;
        final readingBooks = books.where((b) => b.currentPage > 0 && b.currentPage < b.totalPages).length;
        final totalNotes = books.fold<int>(0, (sum, book) => sum + book.noteCount);
        final totalQuotes = 45; // Mock 데이터 (실제로는 API에서 가져와야 함)

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
                    value: totalBooks.toString(),
                    description: '등록된 책',
                  ),
                  _buildStatCard(
                    icon: Icons.bookmark,
                    iconColor: const Color(0xFF10B981),
                    label: '읽는 중',
                    value: readingBooks.toString(),
                    description: '진행 중인 책',
                  ),
                  _buildStatCard(
                    icon: Icons.note,
                    iconColor: const Color(0xFF8B5CF6),
                    label: '노트',
                    value: totalNotes.toString(),
                    description: '작성한 노트',
                  ),
                  _buildStatCard(
                    icon: Icons.format_quote,
                    iconColor: const Color(0xFFFF9800),
                    label: '인용구',
                    value: totalQuotes.toString(),
                    description: '저장한 인용구',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 연속 독서 기록
              _buildReadingStreakCard(),
              const SizedBox(height: 16),
              // 주간 활동
              _buildWeeklyActivitySection(),
              const SizedBox(height: 16),
              // 카테고리별 분포
              _buildCategoryDistributionSection(books),
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

  Widget _buildWeeklyActivitySection() {
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
              const Text(
                '주간 활동',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.headingDark,
                ),
              ),
              Row(
                children: [
                  _buildTimeFilterButton('주', false),
                  const SizedBox(width: 8),
                  _buildTimeFilterButton('월', true),
                  const SizedBox(width: 8),
                  _buildTimeFilterButton('년', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 주간 활동 차트
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarChart('월', 40),
                _buildBarChart('화', 20),
                _buildBarChart('수', 80),
                _buildBarChart('목', 50),
                _buildBarChart('금', 100),
                _buildBarChart('토', 60),
                _buildBarChart('일', 90),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilterButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandLightTint : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.brandBlue : AppTheme.bodyMedium,
          ),
        ),
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

  Widget _buildCategoryDistributionSection(List books) {
    // 카테고리별 책 수 계산
    final categoryCounts = <String, int>{};
    for (var book in books) {
      categoryCounts[book.category] = (categoryCounts[book.category] ?? 0) + 1;
    }

    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedCategories.isNotEmpty ? sortedCategories.first.value : 1;
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
            final percentage = (category.value / maxCount) * 100;
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
                          '${category.value}권',
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
                    category.key,
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
}

/// 활동 탭
class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 활동 히트맵
          _buildActivityHeatmap(),
          const SizedBox(height: 24),
          // 독서 시간
          _buildReadingTimeSection(),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap() {
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
            '활동 히트맵',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 16),
          // 히트맵 그리드 (5주 x 7일)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              // 랜덤 활동 레벨 (0-4)
              final level = (index % 5);
              final colors = [
                AppTheme.divider,
                AppTheme.brandLightTint,
                AppTheme.brandBlue.withOpacity(0.5),
                AppTheme.brandBlue.withOpacity(0.7),
                AppTheme.brandBlue,
              ];

              return Container(
                decoration: BoxDecoration(
                  color: colors[level],
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '적음',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final colors = [
                    AppTheme.divider,
                    AppTheme.brandLightTint,
                    AppTheme.brandBlue.withOpacity(0.5),
                    AppTheme.brandBlue.withOpacity(0.7),
                    AppTheme.brandBlue,
                  ];
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              Text(
                '많음',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingTimeSection() {
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
            '독서 시간',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.headingDark,
            ),
          ),
          const SizedBox(height: 16),
          // 총 독서 시간
          Text(
            '39h 0m',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.brandBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '이번 달 총 독서 시간',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
          const SizedBox(height: 24),
          // 통계
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTimeStat('39h', '평균/월'),
              _buildTimeStat('1.3h', '평균/일'),
              _buildTimeStat('78h', '총 시간'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        const SizedBox(height: 4),
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
}

/// 태그 탭
class _TagsTab extends StatelessWidget {
  const _TagsTab();

  @override
  Widget build(BuildContext context) {
    // Mock 태그 데이터
    final frequentTags = [
      _TagData('중요', const Color(0xFFFF6B6B)),
      _TagData('복습', AppTheme.brandBlue),
      _TagData('질문', const Color(0xFFFFEB3B)),
      _TagData('인용', const Color(0xFF10B981)),
      _TagData('아이디어', const Color(0xFF8B5CF6)),
    ];

    final tagStats = [
      _TagStat('중요', 25, const Color(0xFFFF6B6B)),
      _TagStat('복습', 18, AppTheme.brandBlue),
      _TagStat('질문', 15, const Color(0xFFFFEB3B)),
      _TagStat('인용', 12, const Color(0xFF10B981)),
      _TagStat('아이디어', 10, const Color(0xFF8B5CF6)),
    ];

    final maxCount = tagStats.isNotEmpty ? tagStats.first.count : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 자주 사용하는 태그
          Container(
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
          ),
          const SizedBox(height: 16),
          // 태그별 통계
          Container(
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
          ),
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
