import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        title: const Text('검색'),
        backgroundColor: AppTheme.surfaceWhite,
      ),
      body: const Center(
        child: Text(
          '검색 화면',
          style: TextStyle(
            color: AppTheme.bodyMedium,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

