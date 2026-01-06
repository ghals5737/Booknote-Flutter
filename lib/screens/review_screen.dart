
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
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
            itemCount: 2,
            itemBuilder: (context, index) {
              return _buildReviewCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(int index) {
    final bool isContentVisible = _showContentMap[index] ?? false;
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
        child: isContentVisible ? _buildRevealedContent(index) : _buildPromptContent(index),
      ),
    );
  }

  Widget _buildPromptContent(int index) {
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
                      child: const Column(
                        children: [
                          Text('bbjb,', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
                          SizedBox(height: 4),
                          Text('bbjb', style: TextStyle(fontSize: 14, color: Color(0xFF717182))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '이 책에서 당신이 남긴 문장을 기억하시나요?',
                      style: TextStyle(fontSize: 14, color: Color(0xFF717182)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(2, (i) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == i ? const Color(0xFF3D3D3D) : const Color(0xFFE9E9E9),
                          ),
                        );
                      }),
                    ),
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
                          _showContentMap[index] = true;
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
                    Text(
                      '${_currentPage + 1}/2',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRevealedContent(int index) {
    final selectedAnswer = _selectedAnswers[index];
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
          const Text(
            '"개조차 낯선 인간에게 제주의 새끼로 여겨지는 저 사람들, 나의 몫, 나의 전부, 나의 분할은 그들이 없이는 존재할 수 없다. 내가 가진 것 중 가장 좋은 것이자, 그들에게서 벗어날 수 없는 이유." ',
            style: TextStyle(fontSize: 15, color: Color(0xFF3D3D3D), height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            '📖 bbjb, bbjb',
            style: TextStyle(fontSize: 12, color: Color(0xFF717182)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('당시 나의 생각', style: TextStyle(fontSize: 14, color: Color(0xFF717182))),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF717182)),
                ],
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == i ? const Color(0xFF3D3D3D) : const Color(0xFFE9E9E9),
                ),
              );
            }),
          ),
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
              _buildAnswerButton(index, '있었어요', selectedAnswer, const Color(0xFFF3F3F5), const Color(0xFF3D3D3D)),
              _buildAnswerButton(index, '어려웠어요', selectedAnswer, const Color(0xFFFEF3C7), const Color(0xFFD97706)),
              _buildAnswerButton(index, '기억해요', selectedAnswer, const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
              _buildAnswerButton(index, '쉬웠어요', selectedAnswer, const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => setState(() => _showContentMap[index] = false), child: const Text('다시 가리기', style: TextStyle(fontSize: 13, color: Color(0xFF717182)))),
              const Text('·', style: TextStyle(color: Color(0xFF717182))),
              TextButton(onPressed: () {}, child: const Text('내용에 보기', style: TextStyle(fontSize: 13, color: Color(0xFF717182)))),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentPage + 1}/2',
            style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(int index, String title, String? selectedAnswer, Color selectedBgColor, Color selectedTextColor) {
    final isSelected = selectedAnswer == title;
    return TextButton(
      onPressed: () => setState(() => _selectedAnswers[index] = title),
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
              _buildStatCard('9', '전체 복습'),
              _buildStatCard('3', '복습한 날'),
              _buildStatCard('3', '평균 / 일'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterChip('전체', '9'),
              const SizedBox(width: 8),
              _buildFilterChip('노트', '16'),
              const SizedBox(width: 8),
              _buildFilterChip('인용구', '15'),
            ],
          ),
          const SizedBox(height: 24),
          _buildHistoryGroup(),
        ],
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

  Widget _buildHistoryGroup() {
    return Theme(
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
              child: const Column(
                children: [
                  Text('5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
                  Text('월', style: TextStyle(fontSize: 10, color: Color(0xFF717182))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2026년 1월 5일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
                SizedBox(height: 4),
                Text('4개 복습 완료', style: TextStyle(fontSize: 12, color: Color(0xFF717182))),
              ],
            ),
          ],
        ),
        children: [
          _buildHistoryItem(),
          _buildHistoryItem(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFE9E9E9)),
          const SizedBox(height: 12),
          const Text(
            '"개조차 낯선 인간에게 제주의 새끼로 여겨지는 저 사람들, 나의 몫, 나의 전부, 나의 분할은 그들이 없이는 존재할 수 없다. 내가 가진 것 중 가장 좋은 것이자, 그들에게서 벗어날 수 없는 이유."',
            style: TextStyle(fontSize: 14, color: Color(0xFF3D3D3D), height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📖 bbjb, bbjb',
                style: TextStyle(fontSize: 12, color: Color(0xFF717182)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '어려웠어요',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
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
