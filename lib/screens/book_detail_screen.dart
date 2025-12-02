import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/book/book.dart';
import '../models/book/book_detail_response.dart';
import '../models/note/note.dart';
import '../models/quote/quote.dart';
import '../theme/app_theme.dart';
import '../providers/book/book_providers.dart';
import '../providers/note/note_providers.dart';
import '../providers/quote/quote_providers.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 통합 Provider로 하나만 watch
    final fullDataAsync = ref.watch(bookFullDataProvider(widget.book.id));

    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 100,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.brandBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.book,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Booknote',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
      ),
      body: fullDataAsync.when(
        data: (data) {
          // 레코드 구조분해 할당 (Destructuring)
          final (bookDetail, notes, quotes) = data;

          // 최근 활동 생성 (노트와 인용구를 합쳐서 정렬)
          final activities = <_Activity>[];
          for (var quote in quotes) {
            activities.add(_Activity(
              isNote: false,
              text: quote.text,
              page: quote.page,
              createdAt: quote.createdAt,
              tags: quote.tags,
            ));
          }
          for (var note in notes) {
            activities.add(_Activity(
              isNote: true,
              text: note.title,
              content: note.content,
              page: note.page,
              createdAt: note.createdAt,
              tags: note.tags,
            ));
          }
          activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final recentActivities = activities.take(4).toList();

          return _buildContent(
            bookDetail: bookDetail,
            notes: notes,
            quotes: quotes,
            recentActivities: recentActivities,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로딩 오류: $err')),
      ),
    );
  }

  Widget _buildContent({
    required BookDetailData bookDetail,
    required List<Note> notes,
    required List<Quote> quotes,
    required List<_Activity> recentActivities,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Container(
              color: AppTheme.surfaceWhite,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.brandLightTint,
                        width: 2,
                      ),
                      color: AppTheme.borderSubtle,
                    ),
                    child: bookDetail.coverImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              bookDetail.coverImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.book,
                                  size: 50,
                                  color: AppTheme.metaLight,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.book,
                            size: 50,
                            color: AppTheme.metaLight,
                          ),
                  ),
                  const SizedBox(width: 16),
                  // 책 정보 (오른쪽)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookDetail.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.headingDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bookDetail.author,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 카테고리 태그와 별점을 한 줄에 배치
                        Row(
                          children: [
                            // 카테고리 태그
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.brandLightTint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bookDetail.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.brandBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 별점
                            ...List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < bookDetail.rating
                                    ? Colors.amber
                                    : Colors.grey[300],
                                size: 16,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '(${bookDetail.rating})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),                       
                        const SizedBox(height: 8),
                        // 독서 진행률
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: bookDetail.progress / 100,
                                      minHeight: 6,
                                      backgroundColor: AppTheme.borderSubtle,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        AppTheme.brandBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${bookDetail.progress.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.headingDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${bookDetail.currentPage} / ${bookDetail.totalPages} 페이지',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  bookDetail.updateDate != null
                                      ? '마지막 읽음: ${_formatDateForDisplay(bookDetail.updateDate!)}'
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 노트/인용구 탭
            Container(
              color: AppTheme.surfaceWhite,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.brandBlue,
                    unselectedLabelColor: AppTheme.bodyMedium,
                    indicatorColor: AppTheme.brandBlue,
                    tabs: [
                      Tab(text: '노트 (${notes.length})'),
                      Tab(text: '인용구 (${quotes.length})'),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _NotesTab(notes: notes),
                        _QuotesTab(quotes: quotes),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),      
    );
  }

  String _formatDateForDisplay(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// 최근 활동을 위한 간단한 클래스
class _Activity {
  final bool isNote;
  final String text;
  final String? content; // 노트의 경우 내용
  final int page;
  final DateTime createdAt;
  final List<String>? tags;

  _Activity({
    required this.isNote,
    required this.text,
    this.content,
    required this.page,
    required this.createdAt,
    this.tags,
  });
}

class _ActivityItem extends StatelessWidget {
  final bool isNote;
  final String text;
  final String? content;
  final int page;
  final DateTime createdAt;
  final List<String>? tags;

  const _ActivityItem({
    required this.isNote,
    required this.text,
    this.content,
    required this.page,
    required this.createdAt,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 페이지
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.headingDark,
                  ),
                ),
              ),
              Text(
                'p.$page',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 내용 (노트인 경우에만 표시)
          if (isNote && content != null)
            Text(
              content!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.bodyMedium,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          if (isNote && content != null) const SizedBox(height: 12),
          // 태그와 타임스탬프
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (tags != null && tags!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    ...tags!.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandLightTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.brandBlue,
                          ),
                        ),
                      );
                    }),
                    if (tags!.length > 2)
                      Text(
                        '+${tags!.length - 2}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.metaLight,
                        ),
                      ),
                  ],
                )
              else
                const SizedBox.shrink(),
              Text(
                _formatDateTime(createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}Z';
  }
}

class _NotesTab extends StatelessWidget {
  final List<Note> notes;

  const _NotesTab({required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(
        child: Text(
          '작성한 노트가 없습니다',
          style: TextStyle(color: AppTheme.bodyMedium),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return InkWell(
          onTap: () {
            context.push(
              '/book/${note.bookId}/note/${note.id}',
              extra: note,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider, width: 1),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.headingDark,
                      ),
                    ),
                  ),
                  Text(
                    'p.${note.page}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.metaLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.bodyMedium,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    children: note.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandLightTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.brandBlue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (note.tags.length > 2)
                    Text(
                      '+${note.tags.length - 2}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.metaLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateTime(note.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}Z';
  }
}

class _QuotesTab extends StatelessWidget {
  final List<Quote> quotes;

  const _QuotesTab({required this.quotes});

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) {
      return const Center(
        child: Text(
          '저장한 인용구가 없습니다',
          style: TextStyle(color: AppTheme.bodyMedium),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return InkWell(
          onTap: () {
            context.push(
              '/book/${quote.bookId}/quote/${quote.id}',
              extra: quote,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider, width: 1),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quote.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.headingDark,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Text(
                    'p.${quote.page}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.metaLight,
                    ),
                  ),
                ],
              ),
              if (quote.comment != null && quote.comment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quote.comment!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.bodyMedium,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 8,
                    children: quote.tags.take(2).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandLightTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.brandBlue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (quote.tags.length > 2)
                    Text(
                      '+${quote.tags.length - 2}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.metaLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateTime(quote.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.metaLight,
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}Z';
  }
}


