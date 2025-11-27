import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/auth/user.dart';
import '../../repositories/auth_repository.dart';

/// AuthRepository Provider
/// 실제 API 사용: ApiAuthRepository()
/// Mock 사용: MockAuthRepository()
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(); // 실제 API 사용
  // return MockAuthRepository(); // Mock 사용 (개발/테스트용)
});

/// 현재 사용자 Provider
final currentUserProvider = StateProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// 인증 상태 Provider
final authStatusProvider = Provider<AuthStatus>((ref) {
  final user = ref.watch(currentUserProvider);
  
  if (user == null) {
    return AuthStatus.unauthenticated;
  }
  if (user.isGuest) {
    return AuthStatus.guest;
  }
  return AuthStatus.authenticated;
});

/// 로그인 Provider
final loginProvider = FutureProvider.family<User, LoginParams>((ref, params) async {
  final repository = ref.read(authRepositoryProvider);
  final user = await repository.login(
    params.email,
    params.password,
    rememberMe: params.rememberMe,
  );
  ref.read(currentUserProvider.notifier).state = user;
  return user;
});

/// 회원가입 Provider
final signUpProvider = FutureProvider.family<User, SignUpParams>((ref, params) async {
  final repository = ref.read(authRepositoryProvider);
  final user = await repository.signUp(
    params.name,
    params.email,
    params.password,
  );
  ref.read(currentUserProvider.notifier).state = user;
  return user;
});

/// 소셜 로그인 Provider
final socialLoginProvider = FutureProvider.family<User, SocialLoginType>((ref, type) async {
  final repository = ref.read(authRepositoryProvider);
  final user = type == SocialLoginType.google
      ? await repository.loginWithGoogle()
      : await repository.loginWithGitHub();
  ref.read(currentUserProvider.notifier).state = user;
  return user;
});

/// 게스트 로그인 Provider
final guestLoginProvider = FutureProvider<User>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  final user = await repository.loginAsGuest();
  ref.read(currentUserProvider.notifier).state = user;
  return user;
});

/// 로그아웃 Provider
final logoutProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(authRepositoryProvider);
  await repository.logout();
  ref.read(currentUserProvider.notifier).state = null;
});

/// 파라미터 클래스들
class LoginParams {
  final String email;
  final String password;
  final bool rememberMe;

  LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class SignUpParams {
  final String name;
  final String email;
  final String password;

  SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
}

enum SocialLoginType {
  google,
  github,
}

