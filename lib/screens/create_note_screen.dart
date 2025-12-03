import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book/book_detail_response.dart';
import '../theme/app_theme.dart';
import '../providers/note/note_providers.dart';

class CreateNoteScreen extends ConsumerStatefulWidget {
  final BookDetailData bookDetail;

  const CreateNoteScreen({
    super.key,
    required this.bookDetail,
  });

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pageController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  bool _isImportant = false;
  int _selectedColorIndex = 0;
  final List<String> _tags = [];
  bool _isSaving = false;

  // 하이라이트 색상 목록
  final List<Color> _highlightColors = [
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF81D4FA), // Light Blue
    const Color(0xFFC5E1A5), // Light Green
    const Color(0xFFFFB3BA), // Light Red/Pink
    const Color(0xFFCE93D8), // Light Purple
    const Color(0xFFE0E0E0), // Light Gray
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _pageController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty;
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSave()) return;
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final noteService = ref.read(noteServiceProvider);
      
      await noteService.createNote(
        bookId: widget.bookDetail.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        html: _contentController.text.trim(), // html은 content와 동일하게 설정
        isImportant: _isImportant,
        tagList: _tags,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // true를 반환하여 성공을 알림
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('노트 저장 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 모달 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.metaLight,
                      ),
                    ),
                  ),
                  const Text(
                    '새 노트 작성',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.headingDark,
                    ),
                  ),
                  TextButton(
                    onPressed: (_canSave() && !_isSaving) ? _saveNote : null,
                    child: Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: (_canSave() && !_isSaving)
                            ? AppTheme.brandBlue
                            : AppTheme.metaLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 책 정보 카드
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.divider,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // 책 커버
                            Container(
                              width: 60,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.borderSubtle,
                                  width: 1,
                                ),
                                color: AppTheme.borderSubtle,
                              ),
                              child: widget.bookDetail.coverImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        widget.bookDetail.coverImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.book,
                                            size: 30,
                                            color: AppTheme.metaLight,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.book,
                                      size: 30,
                                      color: AppTheme.metaLight,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // 책 정보
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.bookDetail.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.headingDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.bookDetail.author,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 책 보기 버튼
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppTheme.borderSubtle,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '책 보기',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 중요 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isImportant = !_isImportant;
                              });
                            },
                            icon: Icon(
                              _isImportant ? Icons.star : Icons.star_border,
                              color: _isImportant
                                  ? Colors.amber
                                  : AppTheme.bodyMedium,
                              size: 20,
                            ),
                            label: Text(
                              '중요',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isImportant
                                    ? Colors.amber
                                    : AppTheme.bodyMedium,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: AppTheme.borderSubtle,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 노트 제목 입력
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '노트 제목을 입력하세요',
                          hintStyle: const TextStyle(
                            color: AppTheme.placeholder,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.headingDark,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      // 페이지 번호 입력
                      const Text(
                        '페이지 번호',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '페이지 번호',
                          hintStyle: const TextStyle(
                            color: AppTheme.placeholder,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '총 ${widget.bookDetail.totalPages}페이지',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.metaLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 노트 내용 입력
                      const Text(
                        '노트 내용',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.headingDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: '노트 내용을 입력하세요...',
                          hintStyle: const TextStyle(
                            color: AppTheme.placeholder,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.borderSubtle,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.brandBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.headingDark,
                          height: 1.5,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      // 하이라이트 색상 선택
                      Row(
                        children: [
                          const Icon(
                            Icons.palette,
                            size: 20,
                            color: AppTheme.bodyMedium,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '하이라이트 색상',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.headingDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _highlightColors.asMap().entries.map((entry) {
                          final index = entry.key;
                          final color = entry.value;
                          final isSelected = index == _selectedColorIndex;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorIndex = index;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.brandBlue
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      // 태그 입력
                      const Row(
                        children: [
                          Text(
                            '# 태그',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.headingDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                hintText: '태그를 입력하세요',
                                hintStyle: const TextStyle(
                                  color: AppTheme.placeholder,
                                ),
                                filled: true,
                                fillColor: AppTheme.surfaceWhite,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.borderSubtle,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.borderSubtle,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.brandBlue,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.headingDark,
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.brandBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _addTag,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 태그 목록 표시
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              onDeleted: () => _removeTag(tag),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 18,
                              ),
                              backgroundColor: AppTheme.brandLightTint,
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.brandBlue,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 32), // 하단 여백
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

