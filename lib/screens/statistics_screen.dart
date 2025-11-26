import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: const Text('통계'),
        backgroundColor: AppTheme.surfaceWhite,
      ),
      body: const Center(
        child: Text(
          '통계 화면',
          style: TextStyle(
            color: AppTheme.bodyMedium,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

