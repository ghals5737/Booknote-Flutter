import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'fab_popover_menu.dart';

/// 커스텀 하단 네비게이션 바 (가운데 FAB 포함)
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  bool _showFabMenu = false;
  OverlayEntry? _overlayEntry;

  void _handleFabTap() {
    setState(() {
      _showFabMenu = !_showFabMenu;
    });
    
    if (_showFabMenu) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 배경 오버레이
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFabMenu = false;
                });
                _hideOverlay();
              },
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          // 팝오버 메뉴
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 140,
            bottom: screenHeight - position.dy + 80,
            child: FABPopoverMenu(
              onDismiss: () {
                setState(() {
                  _showFabMenu = false;
                });
                _hideOverlay();
              },
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _handleNavTap(int index) {
    // FAB 버튼(인덱스 2)은 탭하지 않음
    if (index != 2) {
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 하단 네비게이션 바
        Container(
          height: 70,
          decoration: const BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border(
              top: BorderSide(color: AppTheme.divider, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 서재
              _buildNavItem(
                icon: Icons.library_books_outlined,
                activeIcon: Icons.library_books,
                label: '서재',
                index: 0,
                isActive: widget.currentIndex == 0,
              ),
              // 검색
              _buildNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: '검색',
                index: 1,
                isActive: widget.currentIndex == 1,
              ),
              // FAB 공간 (가운데)
              const SizedBox(width: 60),
              // 복습
              _buildNavItem(
                icon: Icons.refresh_outlined,
                activeIcon: Icons.refresh,
                label: '복습',
                index: 3,
                isActive: widget.currentIndex == 3,
              ),
              // 통계
              _buildNavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: '통계',
                index: 4,
                isActive: widget.currentIndex == 4,
              ),
            ],
          ),
        ),
        // FAB 버튼 (가운데) - 수평/수직 정중앙 정렬
        Positioned(
          // 수평 정중앙: 네비게이션 바 너비의 절반에서 FAB 너비의 절반을 뺌
          left: 0,
          right: 0,
          // 수직 정중앙: 네비게이션 바 높이(70)의 절반에서 FAB 높이(60)의 절반을 뺌
          // top: -30은 네비게이션 바 위로 30px 올라가서 FAB의 절반이 위로 나오게 함
          top: 15,
          child: Center(
            child: GestureDetector(
              onTap: _handleFabTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.brandBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _showFabMenu ? Icons.close : Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _handleNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.brandBlue : AppTheme.metaLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.brandBlue : AppTheme.metaLight,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

