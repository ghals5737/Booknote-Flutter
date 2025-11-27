import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'auth_form.dart';

/// 인증 화면 (로그인/회원가입)
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true; // true: 로그인, false: 회원가입

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 그라데이션 배경 (보라색-흰색)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.brandLightTint.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // BookNote 로고
                    _buildLogo(),
                    const SizedBox(height: 32),
                    // 인증 폼 카드
                    AuthForm(isLogin: _isLogin, onToggleMode: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // 로고 아이콘 (보라색 사각형에 흰색 책 아이콘)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.brandBlue,
                AppTheme.brandHover,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.book,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        // 앱 이름
        const Text(
          'BookNote',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.headingDark,
          ),
        ),
        const SizedBox(height: 8),
        // 태그라인
        const Text(
          '독서 노트와 함께 성장하세요',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

