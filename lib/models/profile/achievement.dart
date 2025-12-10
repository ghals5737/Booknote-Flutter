import 'package:flutter/material.dart';

/// 업적 모델
class Achievement {
  final String id;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final bool isCompleted;

  Achievement({
    required this.id,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.isCompleted,
  });
}

