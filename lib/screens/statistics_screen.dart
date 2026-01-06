
import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('통계', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
            const SizedBox(height: 8),
            const Text('나의 독서 여정을 한눈에', style: TextStyle(fontSize: 16, color: Color(0xFF717182))),
            const SizedBox(height: 24),
            _buildTopCards(),
            const SizedBox(height: 16),
            _buildInfoCard('전체 책', '42', Icons.book_outlined),
            _buildInfoCard('읽은 책', '28', Icons.check_circle_outline),
            _buildInfoCard('누적 페이지', '12,847', Icons.article_outlined),
            _buildInfoCard('작성한 노트', '156', Icons.note_alt_outlined),
            const SizedBox(height: 16),
            _buildReadingStreakCard(),
            const SizedBox(height: 24),
            _buildMonthlyReadingChart(),
            const SizedBox(height: 24),
            _buildCategoryDistributionChart(),
            const SizedBox(height: 24),
            _buildFrequentTagsCard(),
            const SizedBox(height: 24),
            _buildTagStatsCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF5D4A3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.calendar_today, color: Colors.white, size: 14), SizedBox(width: 4), Text('월간 목표', style: TextStyle(fontSize: 12, color: Colors.white70))]),
                const SizedBox(height: 8),
                const Text.rich(TextSpan(children: [TextSpan(text: '3', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)), TextSpan(text: '/5권', style: TextStyle(fontSize: 14, color: Colors.white))])),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(999), child: const LinearProgressIndicator(value: 0.6, backgroundColor: Colors.white30, valueColor: AlwaysStoppedAnimation(Colors.white))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF9A825), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.local_fire_department, color: Colors.white, size: 14), SizedBox(width: 4), Text('연속 독서', style: TextStyle(fontSize: 12, color: Colors.white70))]),
                const SizedBox(height: 8),
                const Text('7일째', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('계속 유지하세요! 🔥', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF795548), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.bookmark, color: Colors.white, size: 14), SizedBox(width: 4), Text('올해', style: TextStyle(fontSize: 12, color: Colors.white70))]),
                const SizedBox(height: 8),
                const Text('23권', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('완독 🔥', style: TextStyle(fontSize: 12, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF795548), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))]),
          Icon(icon, color: Colors.white70, size: 28),
        ],
      ),
    );
  }

  Widget _buildReadingStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFE57373), Color(0xFFD32F2F)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.whatshot, color: Colors.white, size: 16), SizedBox(width: 8), Text('연속 독서', style: TextStyle(color: Colors.white70, fontSize: 14))]),
          const SizedBox(height: 8),
          const Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text('12', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)), Text('일', style: TextStyle(color: Colors.white, fontSize: 18))]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) => _buildStreakBar(index, index == 6)).reversed.toList(),
          ),
          const SizedBox(height: 20),
          const Center(child: Text('멋져요! 꾸준한 독서를 이어가고 있어요✨', style: TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStreakBar(int day, bool isToday) {
    final heights = [20.0, 30.0, 25.0, 40.0, 50.0, 45.0, 60.0];
    return Column(children: [Container(width: 30, height: heights[day], decoration: BoxDecoration(color: Colors.white.withOpacity(isToday ? 1.0 : 0.8), borderRadius: BorderRadius.circular(8))), const SizedBox(height: 4), if (isToday) const Text('+5', style: TextStyle(color: Colors.white, fontSize: 12))]);
  }

  Widget _buildMonthlyReadingChart() {
    // Placeholder for bar chart
    return _buildChartCard('월별 독서량', Container(height: 150, alignment: Alignment.center, child: const Text('월별 독서량 바 차트', style: TextStyle(color: Color(0xFF717182)))));
  }

  Widget _buildCategoryDistributionChart() {
    // Placeholder for pie chart
    return _buildChartCard('카테고리별 독서 분포', 
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:[
          SizedBox(
            width: 150, 
            height: 150, 
            child:SizedBox(child: CustomPaint(painter: PieChartPainter()))
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  _buildLegendItem(Color(0xFF5D4A3A), '소설', '31.9%'),
                  _buildLegendItem(Color(0xFF8D6E63), '자기계발', '25.5%'),
                  _buildLegendItem(Color(0xFFA1887F), '에세이', '17.0%'),
                  _buildLegendItem(Color(0xFFBCAAA4), '과학', '10.6%'),
                  _buildLegendItem(Color(0xFFD7CCC8), '역사', '8.5%'),
                  _buildLegendItem(Color(0xFFEFEBE9), '철학', '6.4%'),
            ],
          )
        ]
      )
    );
  }

    static Widget _buildLegendItem(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF3D3D3D))),
          const SizedBox(width: 16),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF717182))),
        ],
      ),
    );
  }

  Widget _buildFrequentTagsCard() {
    final tags = {'성장': 24, '사랑': 18, '인생': 15, '우정': 12, '가족': 10};
    return _buildChartCard('자주 사용하는 태그', 
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: tags.entries.map((e) => Chip(label: Text('# ${e.key} (${e.value})'), backgroundColor: const Color(0xFFF3F3F5), labelStyle: const TextStyle(color: Color(0xFF3D3D3D)))).toList(),
      )
    );
  }

  Widget _buildTagStatsCard() {
    final tags = {'# 성장': 24, '# 사랑': 18, '# 인생': 15, '# 우정': 12, '# 가족': 10};
    return _buildChartCard('태그별 통계', 
      Column(
        children: tags.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text(e.key, style: const TextStyle(fontSize: 14, color: Color(0xFF3D3D3D))),
                const SizedBox(width: 16),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: e.value / tags.values.first, backgroundColor: const Color(0xFFF3F3F5), valueColor: const AlwaysStoppedAnimation(Color(0xFF5D4A3A))))),
                const SizedBox(width: 16),
                Text('${e.value}회', style: const TextStyle(fontSize: 14, color: Color(0xFF717182))),
              ],
            ),
          );
        }).toList(),
      )
    );
  }


  Widget _buildChartCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE9E9E9))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3D3D3D))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final data = [0.319, 0.255, 0.17, 0.106, 0.085, 0.064];
    final colors = [const Color(0xFF5D4A3A), const Color(0xFF8D6E63), const Color(0xFFA1887F), const Color(0xFFBCAAA4), const Color(0xFFD7CCC8), const Color(0xFFEFEBE9)];
    double startAngle = -math.pi / 2;
    for (var i = 0; i < data.length; i++) {
      final sweepAngle = data[i] * 2 * math.pi;
      paint.color = colors[i];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
