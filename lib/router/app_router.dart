import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/library_screen.dart';
import '../screens/search_screen.dart';
import '../screens/review_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/book_detail_screen.dart';
import '../providers/auth/auth_providers.dart';
import '../models/auth/user.dart';
import '../models/book/book.dart';
import '../widgets/bottom_nav_bar.dart';
import '../theme/app_theme.dart';

/// 앱 라우터 설정
final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final isAuthenticated = authStatus != AuthStatus.unauthenticated;
      final isAuthRoute = state.matchedLocation == '/auth';

      // 인증되지 않은 사용자는 로그인 화면으로
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }

      // 인증된 사용자가 로그인 화면에 있으면 홈으로
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // 인증 화면
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      // 메인 화면 (하단 네비게이션 포함)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainScreen(),
        routes: [
          // 책 상세 화면
          GoRoute(
            path: 'book/:bookId',
            name: 'bookDetail',
            builder: (context, state) {
              final book = state.extra as Book?;
              if (book == null) {
                final bookId = int.parse(state.pathParameters['bookId']!);
                return BookDetailScreen(
                  book: Book(
                    id: bookId,
                    title: '알 수 없는 책',
                    author: '알 수 없는 저자',
                    category: '기타',
                    totalPages: 0,
                    currentPage: 0,
                  ),
                );
              }
              return BookDetailScreen(book: book);
            },
          ),
        ],
      ),
    ],
  );
});

/// 메인 화면 (하단 네비게이션 포함)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const SearchScreen(),
    const ReviewScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

