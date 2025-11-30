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
import '../screens/create_note_screen.dart';
import '../screens/create_quote_screen.dart';
import '../screens/note_detail_screen.dart';
import '../screens/edit_note_screen.dart';
import '../screens/quote_detail_screen.dart';
import '../providers/auth/auth_providers.dart';
import '../models/auth/user.dart';
import '../models/book/book.dart';
import '../models/book/book_detail_response.dart';
import '../models/note/note.dart';
import '../models/quote/quote.dart';
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
            routes: [
              // 노트 작성 화면
              GoRoute(
                path: 'note/create',
                name: 'createNote',
                builder: (context, state) {
                  final bookDetail = state.extra as BookDetailData?;
                  if (bookDetail == null) {
                    // bookDetail이 없으면 이전 화면으로 돌아가기
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
                    // bookDetail이 없으면 이전 화면으로 돌아가기
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
              ),
            ],
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

