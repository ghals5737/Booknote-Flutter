import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 복습 관리 화면
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: const Text('복습'),
        backgroundColor: AppTheme.surfaceWhite,
      ),
      body: const Center(
        child: Text(
          '복습 화면',
          style: TextStyle(
            color: AppTheme.bodyMedium,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

