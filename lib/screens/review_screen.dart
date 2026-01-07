
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review/review_models.dart';
import '../providers/review/review_providers.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final Map<int, bool> _showContentMap = {};
  final Map<int, String> _selectedAnswers = {};
  late PageController _pageController;
  int _currentPage = 0;
  String _selectedFilter = '전체';

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        if (_pageController.page?.round() != _currentPage) {
          setState(() {
            _currentPage = _pageController.page!.round();
          });
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 60,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF5D4A3A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.book, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'Booknote',
                style: TextStyle(
                  color: Color(0xFF3D3D3D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF3D3D3D)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Color(0xFF3D3D3D)),
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '오늘의 복습'),
              Tab(text: '복습 기록'),
            ],
            labelColor: Color(0xFF3D3D3D),
            unselectedLabelColor: Color(0xFF717182),
            indicatorColor: Color(0xFF5D4A3A),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTodayReview(),
            _buildReviewHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayReview() {
    final todayReviewAsync = ref.watch(todayReviewProvider);

    return todayReviewAsync.when(
      data: (reviewData) {
        final items = reviewData.items.where((item) => !item.completed).toList();

        if (items.isEmpty) {
          return const Center(child: Text('오늘 복습할 항목이 없습니다.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9E9E9)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Color(0xFF717182)),
                        SizedBox(width: 8),
                        Text(
                          '오늘',
                          style: TextStyle(fontSize: 14, color: Color(0xFF3D3D3D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '✨ 과거의 나를 다시 만나는 시간',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(items[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }

  Widget _buildReviewCard(ReviewItem item) {
    final bool isContentVisible = _showContentMap[item.id] ?? false;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE9E9E9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isContentVisible ? _buildRevealedContent(item) : _buildPromptContent(item),
      ),
    );
  }

  Widget _buildPromptContent(ReviewItem item) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco_outlined, color: Color(0xFF4A7C59)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)]),
                      child: Column(
                        children: [
                          Text(item.bookTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
                          const SizedBox(height: 4),
                          Text(item.itemType == 'NOTE' ? item.note?.title ?? '' : item.quote?.text ?? '', style: const TextStyle(fontSize: 14, color: Color(0xFF717182)), maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '이 책에서 당신이 남긴 문장을 기억하시나요?',
                      style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                    ),
                    const SizedBox(height: 16),
                    // ... Page indicator ...
                    const SizedBox(height: 16),
                    const Text(
                      '지난번엔 어려웠어요라고 하셨어요',
                      style: TextStyle(fontSize: 13, color: Color(0xFF717182)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showContentMap[item.id] = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D4A3A),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        '내용 확인하기',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ... Page count ...
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRevealedContent(ReviewItem item) {
    final selectedAnswer = _selectedAnswers[item.id];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.eco_outlined, color: Color(0xFF4A7C59)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.itemType == 'NOTE' ? item.note?.content ?? '' : item.quote?.text ?? '',
            style: const TextStyle(fontSize: 15, color: Color(0xFF3D3D3D), height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '📖 ${item.bookTitle}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF717182)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // ... My thought section ...
          const SizedBox(height: 16),
          // ... Page indicator ...
          const SizedBox(height: 30),
          const Text('얼마나 잘 기억하고 있나요?', style: TextStyle(fontSize: 13, color: Color(0xFF717182)), textAlign: TextAlign.center,),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAnswerButton(item.id, 'EASY', '쉬웠어요', selectedAnswer, const Color(0xFFDCFCE7), const Color(0xFF16A34A), item.reviewId, item.id),
              _buildAnswerButton(item.id, 'MEDIUM', '기억해요', selectedAnswer, const Color(0xFFDBEAFE), const Color(0xFF2563EB), item.reviewId, item.id),
              _buildAnswerButton(item.id, 'HARD', '어려웠어요', selectedAnswer, const Color(0xFFFEF3C7), const Color(0xFFD97706), item.reviewId, item.id),
              _buildAnswerButton(item.id, 'FORGOT', '잊었어요', selectedAnswer, const Color(0xFFF3F3F5), const Color(0xFF3D3D3D), item.reviewId, item.id),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => setState(() => _showContentMap[item.id] = false), child: const Text('다시 가리기', style: TextStyle(fontSize: 13, color: Color(0xFF717182)))),
              const Text('·', style: TextStyle(color: Color(0xFF717182))),
              TextButton(onPressed: () {}, child: const Text('내용에 보기', style: TextStyle(fontSize: 13, color: Color(0xFF717182)))),
            ],
          ),
          const SizedBox(height: 4),
          // ... Page count ...
        ],
      ),
    );
  }

  Widget _buildAnswerButton(int itemId, String responseType, String title, String? selectedAnswer, Color selectedBgColor, Color selectedTextColor, int reviewId, int reviewItemId) {
    final isSelected = selectedAnswer == responseType;
    return TextButton(
      onPressed: () {
        setState(() => _selectedAnswers[itemId] = responseType);
        ref.read(reviewCompleterProvider.notifier).complete(reviewId, reviewItemId, responseType);
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? selectedBgColor : const Color(0xFFF3F3F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? selectedTextColor : const Color(0xFF3D3D3D),
          fontWeight: isSelected? FontWeight.bold: FontWeight.normal
        ),
      ),
    );
  }

  // --- 복습 기록 탭 위젯 ---
  Widget _buildReviewHistory() {
    final historyAsync = ref.watch(reviewHistoryProvider);

    return historyAsync.when(
      data: (historyData) {
        // 통계 계산
        final totalReviews = historyData.totalElements;
        final totalSessions = historyData.content.length;
        final completedSessions = historyData.content.where((s) => s.completed).length;
        final avgPerDay = totalSessions > 0 ? (totalReviews / totalSessions).round() : 0;

        // 노트와 인용구 개수 계산
        int noteCount = 0;
        int quoteCount = 0;
        for (var session in historyData.content) {
          for (var item in session.reviewItems) {
            if (item.itemType == 'NOTE') {
              noteCount++;
            } else if (item.itemType == 'QUOTE') {
              quoteCount++;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8F8F8),
                  border: Border.all(color: const Color(0xFFE9E9E9)),
                ),
                child: const Icon(Icons.refresh, color: Color(0xFF717182), size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                '복습 히스토리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D)),
              ),
              const SizedBox(height: 8),
              const Text(
                '꾸준히 복습한 나의 발자취를 살펴보세요',
                style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildStatCard(totalReviews.toString(), '전체 복습'),
                  _buildStatCard(completedSessions.toString(), '복습한 날'),
                  _buildStatCard(avgPerDay.toString(), '평균 / 일'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFilterChip('전체', totalReviews.toString()),
                  const SizedBox(width: 8),
                  _buildFilterChip('노트', noteCount.toString()),
                  const SizedBox(width: 8),
                  _buildFilterChip('인용구', quoteCount.toString()),
                ],
              ),
              const SizedBox(height: 24),
              if (historyData.content.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      '복습 기록이 없습니다',
                      style: TextStyle(fontSize: 16, color: Color(0xFF717182)),
                    ),
                  ),
                )
              else
                ...historyData.content.map((session) => _buildHistorySession(session)).toList(),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(0xFF717182)),
              const SizedBox(height: 16),
              Text(
                '오류가 발생했습니다',
                style: const TextStyle(fontSize: 16, color: Color(0xFF3D3D3D)),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF717182)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E9E9)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF717182))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String count) {
    final bool isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF3D3D3D),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
      backgroundColor: const Color(0xFFF3F3F5),
      selectedColor: const Color(0xFF5D4A3A),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9999),
        side: const BorderSide(color: Colors.transparent),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  Widget _buildHistorySession(ReviewHistorySession session) {
    final date = session.plannedTime ?? session.completedTime;
    final month = date != null ? date.month : 0;
    final day = date != null ? date.day : 0;
    final year = date != null ? date.year : 0;
    final formattedDate = date != null 
        ? '${year}년 ${month}월 ${day}일'
        : '날짜 없음';
    final completedCount = session.reviewItems.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE9E9E9)),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE9E9E9)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9E9E9)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$month',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3D3D3D),
                      ),
                    ),
                    const Text(
                      '월',
                      style: TextStyle(fontSize: 10, color: Color(0xFF717182)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D3D3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount개 복습 ${session.completed ? '완료' : '미완료'}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF717182)),
                  ),
                ],
              ),
            ],
          ),
          children: session.reviewItems
              .map((item) => _buildHistoryItem(item))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ReviewItem item) {
    final isNote = item.itemType == 'NOTE';
    final content = isNote 
        ? (item.note?.content ?? '')
        : (item.quote?.text ?? '');
    final bookTitle = item.bookTitle;
    final responseType = item.completedTime != null ? '완료' : '미완료';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFE9E9E9)),
          const SizedBox(height: 12),
          Text(
            isNote ? item.note?.title ?? '' : '"$content"',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3D3D3D),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📖 $bookTitle',
                style: const TextStyle(fontSize: 12, color: Color(0xFF717182)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.completed
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  responseType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: item.completed
                        ? const Color(0xFF065F46)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
