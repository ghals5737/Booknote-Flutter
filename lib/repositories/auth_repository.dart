import '../models/auth/user.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

/// 인증 Repository 인터페이스
abstract class AuthRepository {
  Future<User> login(String email, String password, {bool rememberMe = false});
  Future<User> signUp(String name, String email, String password);
  Future<User> loginWithGoogle();
  Future<User> loginWithGitHub();
  Future<User> loginAsGuest();
  Future<void> logout();
  Future<void> resetPassword(String email);
  User? getCurrentUser();
  bool get isAuthenticated;
  Future<void> initialize(); // 앱 시작 시 저장된 사용자 정보 로드
}

/// 실제 API를 사용하는 인증 Repository 구현
class ApiAuthRepository implements AuthRepository {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isAuthenticated = false;

  @override
  Future<void> initialize() async {
    // 앱 시작 시 저장된 토큰과 사용자 정보 확인
    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      final userInfo = await TokenStorage.getUserInfo();
      if (userInfo != null) {
        _currentUser = User(
          id: userInfo['id']!,
          email: userInfo['email']!,
          name: userInfo['name']!,
          isGuest: false,
        );
        _isAuthenticated = true;
      }
    }
  }

  @override
  Future<User> login(String email, String password, {bool rememberMe = false}) async {
    // 입력 검증
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일과 비밀번호를 입력해주세요.');
    }

    // 실제 API 호출
    final response = await _authService.login(email, password);

    if (response.success && response.data != null) {
      // 토큰 저장
      await TokenStorage.saveAccessToken(response.data!.accessToken);
      await TokenStorage.saveRefreshToken(response.data!.refreshToken);

      // 사용자 정보 저장 (API에서 사용자 정보를 받지 않으므로 이메일 기반으로 생성)
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userName = email.split('@')[0];
      await TokenStorage.saveUserInfo(
        id: userId,
        email: email,
        name: userName,
      );

      // 현재 사용자 설정
      _currentUser = User(
        id: userId,
        email: email,
        name: userName,
        isGuest: false,
      );
      _isAuthenticated = true;

      return _currentUser!;
    } else {
      throw Exception(response.message.isNotEmpty 
          ? response.message 
          : '로그인에 실패했습니다.');
    }
  }

  @override
  Future<User> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('모든 필드를 입력해주세요.');
    }

    if (password.length < 6) {
      throw Exception('비밀번호는 6자 이상이어야 합니다.');
    }

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      name: 'Google User',
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> loginWithGitHub() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: 'github_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@github.com',
      name: 'GitHub User',
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> loginAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@booknote.com',
      name: '게스트',
      isGuest: true,
    );
    _isAuthenticated = false; // 게스트는 인증되지 않은 상태
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    // 토큰 및 사용자 정보 삭제
    await TokenStorage.clearAll();
    _currentUser = null;
    _isAuthenticated = false;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty) {
      throw Exception('이메일을 입력해주세요.');
    }
    // Mock: 비밀번호 재설정 이메일 전송 성공
  }

  @override
  User? getCurrentUser() => _currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
}

/// Mock 인증 Repository 구현 (개발/테스트용)
class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  bool _isAuthenticated = false;

  @override
  Future<void> initialize() async {
    // Mock에서는 초기화 불필요
  }

  @override
  Future<User> login(String email, String password, {bool rememberMe = false}) async {
    // Mock: 1초 대기 후 성공
    await Future.delayed(const Duration(seconds: 1));
    
    // 간단한 검증
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일과 비밀번호를 입력해주세요.');
    }

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@')[0],
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('모든 필드를 입력해주세요.');
    }

    if (password.length < 6) {
      throw Exception('비밀번호는 6자 이상이어야 합니다.');
    }

    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      name: 'Google User',
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> loginWithGitHub() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: 'github_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@github.com',
      name: 'GitHub User',
      isGuest: false,
    );
    _isAuthenticated = true;
    return _currentUser!;
  }

  @override
  Future<User> loginAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@booknote.com',
      name: '게스트',
      isGuest: true,
    );
    _isAuthenticated = false; // 게스트는 인증되지 않은 상태
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _isAuthenticated = false;
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty) {
      throw Exception('이메일을 입력해주세요.');
    }
    // Mock: 비밀번호 재설정 이메일 전송 성공
  }

  @override
  User? getCurrentUser() => _currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated && _currentUser != null;
}

