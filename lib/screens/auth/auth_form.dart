import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth/auth_providers.dart';
import 'package:go_router/go_router.dart';

/// 인증 폼 (로그인/회원가입)
class AuthForm extends ConsumerStatefulWidget {
  final bool isLogin;
  final VoidCallback onToggleMode;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onToggleMode,
  });

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.isLogin) {
        final loginAsync = ref.read(loginProvider(LoginParams(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        )).future);
        
        await loginAsync;
        if (mounted) {
          context.go('/');
        }
      } else {
        final signUpAsync = ref.read(signUpProvider(SignUpParams(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        )).future);
        
        await signUpAsync;
        if (mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSocialLogin(SocialLoginType type) async {
    try {
      final socialAsync = ref.read(socialLoginProvider(type).future);
      await socialAsync;
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('소셜 로그인 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    try {
      final guestAsync = ref.read(guestLoginProvider.future);
      await guestAsync;
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게스트 로그인 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 탭 전환
            _buildTabs(),
            const SizedBox(height: 24),
            // 이름 필드 (회원가입만)
            if (!widget.isLogin) ...[
              _buildTextField(
                controller: _nameController,
                label: '이름',
                icon: Icons.person_outline,
                hint: '이름을 입력하세요',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            // 이메일 필드
            _buildTextField(
              controller: _emailController,
              label: '이메일',
              icon: Icons.email_outlined,
              hint: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!value.contains('@')) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 비밀번호 필드
            _buildTextField(
              controller: _passwordController,
              label: '비밀번호',
              icon: Icons.lock_outline,
              hint: '비밀번호를 입력하세요',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.metaLight,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                if (!widget.isLogin && value.length < 6) {
                  return '비밀번호는 6자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 로그인 옵션 (로그인만)
            if (widget.isLogin) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppTheme.brandBlue,
                      ),
                      const Text(
                        '로그인 상태 유지',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 찾기 (추후 구현)
                    },
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.brandBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            // 제출 버튼
            _buildSubmitButton(),
            const SizedBox(height: 24),
            // 구분선
            _buildDivider(),
            const SizedBox(height: 24),
            // 소셜 로그인 버튼
            _buildSocialButtons(),
            const SizedBox(height: 16),
            // 게스트 로그인
            _buildGuestButton(),
            const SizedBox(height: 16),
            // 이용약관
            _buildTermsText(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab('로그인', widget.isLogin),
          ),
          Expanded(
            child: _buildTab('회원가입', !widget.isLogin),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onToggleMode,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: AppTheme.headingDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.headingDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.placeholder),
              prefixIcon: Icon(icon, color: AppTheme.metaLight),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.brandBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        widget.isLogin ? '로그인' : '회원가입',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderSubtle)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.metaLight,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.borderSubtle)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.g_mobiledata,
            label: 'Google',
            onTap: () => _handleSocialLogin(SocialLoginType.google),
            isGoogle: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.code,
            label: 'GitHub',
            onTap: () => _handleSocialLogin(SocialLoginType.github),
            isGoogle: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isGoogle,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppTheme.surfaceWhite,
        foregroundColor: AppTheme.headingDark,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGoogle)
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://www.google.com/favicon.ico',
                  ),
                ),
              ),
            )
          else
            Icon(icon, size: 20, color: AppTheme.headingDark),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton() {
    return Center(
      child: TextButton(
        onPressed: _handleGuestLogin,
        child: const Text(
          '게스트로 둘러보기 →',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.headingDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.metaLight,
          ),
          children: [
            const TextSpan(text: '로그인하면 '),
            TextSpan(
              text: '이용약관',
              style: const TextStyle(color: AppTheme.brandBlue),
              recognizer: null, // GestureRecognizer 추가 가능
            ),
            const TextSpan(text: ' 및 '),
            TextSpan(
              text: '개인정보처리방침',
              style: const TextStyle(color: AppTheme.brandBlue),
              recognizer: null,
            ),
            const TextSpan(text: '에 동의하게 됩니다.'),
          ],
        ),
      ),
    );
  }
}

