import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart';

/// design.json 기반 BottomTabBar 스타일 (커스텀 FAB 포함)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}

