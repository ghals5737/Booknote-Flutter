import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('홈'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('홈 화면'),
      ),
    );
  }
}

