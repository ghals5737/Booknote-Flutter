import 'package:booknoteflutter/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/search_screen.dart';
import '../screens/review_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/book_detail_screen.dart';
import '../screens/create_note_screen.dart';
import '../screens/create_quote_screen.dart';
import '../screens/note_detail_screen.dart';
import '../screens/edit_note_screen.dart';
import '../screens/quote_detail_screen.dart';
import '../screens/edit_quote_screen.dart';
import '../screens/add_book_screen.dart';
import '../providers/auth/auth_providers.dart';
import '../models/auth/user.dart';
import '../models/book/book.dart';
import '../models/book/book_detail_response.dart';
import '../models/note/note.dart';
import '../models/quote/quote.dart';
import '../widgets/custom_bottom_nav_bar.dart';
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
      // 메인 화면 (하단 네비게이션 포함) - ShellRoute로 변경
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // 홈 화면들
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/review',
            name: 'review',
            builder: (context, state) => const ReviewScreen(),
          ),
          GoRoute(
            path: '/statistics',
            name: 'statistics',
            builder: (context, state) => const StatisticsScreen(),
          ),
          // 프로필 화면
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // 책 추가 화면
          GoRoute(
            path: '/book/add',
            name: 'addBook',
            builder: (context, state) => const AddBookScreen(),
          ),
          // 책 상세 화면
          GoRoute(
            path: '/book/:bookId',
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
            routes: [
              // 노트 작성 화면
              GoRoute(
                path: 'note/create',
                name: 'createNote',
                builder: (context, state) {
                  final bookDetail = state.extra as BookDetailData?;
                  if (bookDetail == null) {
                    return const Scaffold(
                      body: Center(child: Text('책 정보를 불러올 수 없습니다')),
                    );
                  }
                  return CreateNoteScreen(bookDetail: bookDetail);
                },
              ),
              // 인용구 추가 화면
              GoRoute(
                path: 'quote/create',
                name: 'createQuote',
                builder: (context, state) {
                  final bookDetail = state.extra as BookDetailData?;
                  if (bookDetail == null) {
                    return const Scaffold(
                      body: Center(child: Text('책 정보를 불러올 수 없습니다')),
                    );
                  }
                  return CreateQuoteScreen(bookDetail: bookDetail);
                },
              ),
              // 노트 상세 화면
              GoRoute(
                path: 'note/:noteId',
                name: 'noteDetail',
                builder: (context, state) {
                  final note = state.extra as Note?;
                  final bookId = int.parse(state.pathParameters['bookId']!);
                  if (note == null) {
                    return const Scaffold(
                      body: Center(child: Text('노트 정보를 불러올 수 없습니다')),
                    );
                  }
                  return NoteDetailScreen(note: note, bookId: bookId);
                },
                routes: [
                  // 노트 수정 화면
                  GoRoute(
                    path: 'edit',
                    name: 'editNote',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      if (extra == null) {
                        return const Scaffold(
                          body: Center(child: Text('노트 정보를 불러올 수 없습니다')),
                        );
                      }
                      final note = extra['note'] as Note;
                      final bookDetail = extra['bookDetail'] as BookDetailData;
                      return EditNoteScreen(note: note, bookDetail: bookDetail);
                    },
                  ),
                ],
              ),
              // 인용구 상세 화면
              GoRoute(
                path: 'quote/:quoteId',
                name: 'quoteDetail',
                builder: (context, state) {
                  final quote = state.extra as Quote?;
                  final bookId = int.parse(state.pathParameters['bookId']!);
                  if (quote == null) {
                    return const Scaffold(
                      body: Center(child: Text('인용구 정보를 불러올 수 없습니다')),
                    );
                  }
                  return QuoteDetailScreen(quote: quote, bookId: bookId);
                },
                routes: [
                  // 인용구 수정 화면
                  GoRoute(
                    path: 'edit',
                    name: 'editQuote',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      if (extra == null) {
                        return const Scaffold(
                          body: Center(child: Text('인용구 정보를 불러올 수 없습니다')),
                        );
                      }
                      final quote = extra['quote'] as Quote;
                      final bookDetail = extra['bookDetail'] as BookDetailData;
                      return EditQuoteScreen(quote: quote, bookDetail: bookDetail);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// 메인 화면 (하단 네비게이션 포함) - ShellRoute용
class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _getCurrentIndex(String location) {
    if (location == '/' || location.startsWith('/book/add')) return 0; // 서재
    if (location.startsWith('/search')) return 1; // 검색
    if (location.startsWith('/review')) return 3; // 복습
    if (location.startsWith('/statistics')) return 4; // 통계
    // 책 상세, 노트 상세, 인용구 상세 등은 현재 인덱스 유지 (변경하지 않음)
    return 0; // 기본값: 서재
  }

  void _handleNavTap(int index, BuildContext context) {
    final router = GoRouter.of(context);
    switch (index) {
      case 0:
        router.go('/');
        break;
      case 1:
        router.go('/search');
        break;
      case 3:
        router.go('/review');
        break;
      case 4:
        router.go('/statistics');
        break;
      default:
        router.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleNavTap(index, context),
      ),
    );
  }
}

