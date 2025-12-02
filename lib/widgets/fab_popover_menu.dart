import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// FAB 팝오버 메뉴
class FABPopoverMenu extends StatelessWidget {
  final VoidCallback onDismiss;

  const FABPopoverMenu({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 메뉴 내부 탭은 이벤트 전파 방지
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 메뉴 컨테이너
          Container(
            width: 280,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 책 추가
                _buildMenuItem(
                  context: context,
                  icon: Icons.book,
                  iconColor: AppTheme.brandBlue,
                  title: '책 추가',
                  subtitle: '새로운 책을 서재에 추가',
                  onTap: () {
                    onDismiss();
                    context.push('/book/add');
                  },
                ),
                const Divider(height: 1, color: AppTheme.divider),
                // 노트 추가
                _buildMenuItem(
                  context: context,
                  icon: Icons.note_add,
                  iconColor: const Color(0xFF10B981), // Green
                  title: '노트 추가',
                  subtitle: '독서 노트 작성',
                  onTap: () {
                    onDismiss();
                    // TODO: 노트 추가 화면으로 이동 (책 선택 필요)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('노트 추가 기능은 준비 중입니다'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppTheme.divider),
                // 인용구 추가
                _buildMenuItem(
                  context: context,
                  icon: Icons.format_quote,
                  iconColor: const Color(0xFF8B5CF6), // Purple
                  title: '인용구 추가',
                  subtitle: '마음에 드는 구절 저장',
                  onTap: () {
                    onDismiss();
                    // TODO: 인용구 추가 화면으로 이동 (책 선택 필요)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('인용구 추가 기능은 준비 중입니다'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 아래쪽 화살표
          Positioned(
            bottom: -8,
            left: (280 - 20) / 2,
            child: CustomPaint(
              size: const Size(20, 10),
              painter: _ArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.headingDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
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
    );
  }
}

/// 아래쪽 화살표 페인터
class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.surfaceWhite
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

