import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book/book_detail_response.dart';
import '../theme/app_theme.dart';
import '../providers/quote/quote_providers.dart';

class CreateQuoteScreen extends ConsumerStatefulWidget {
  final BookDetailData bookDetail;

  const CreateQuoteScreen({
    super.key,
    required this.bookDetail,
  });

  @override
  ConsumerState<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends ConsumerState<CreateQuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quoteController = TextEditingController();
  final _pageController = TextEditingController();
  final _memoController = TextEditingController();

  bool _isImportant = false;
  bool _isSaving = false;
  static const int _maxQuoteLength = 1000;

  @override
  void dispose() {
    _quoteController.dispose();
    _pageController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  bool _canSave() {
    return _quoteController.text.trim().isNotEmpty &&
        _pageController.text.trim().isNotEmpty;
  }

  Future<void> _saveQuote() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSave()) return;
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final quoteService = ref.read(quoteServiceProvider);
      
      // 페이지 번호를 정수로 변환
      final page = int.tryParse(_pageController.text.trim()) ?? 0;
      
      await quoteService.createQuote(
        bookId: widget.bookDetail.id,
        text: _quoteController.text.trim(),
        page: page,
      );

      if (mounted) {
        Navigator.of(context).pop(true); // true를 반환하여 성공을 알림
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인용구 저장 실패: ${e.toString()}'),
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundCanvas,
      appBar: AppBar(
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // 헤더
              const Text(
                '새 인용구 추가',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.headingDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.bookDetail.title}에서 인상 깊은 구절을 기록해보세요',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
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
                                errorBuilder: (context, error, stackTrace) {
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
              // 인용구 내용 카드
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          '인용구 내용',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.headingDark,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quoteController,
                      maxLines: 6,
                      maxLength: _maxQuoteLength,
                      decoration: InputDecoration(
                        hintText: '인상 깊은 구절을 입력하세요...',
                        hintStyle: const TextStyle(
                          color: AppTheme.placeholder,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundCanvas,
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
                        counterText: '',
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.headingDark,
                        height: 1.5,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_quoteController.text.length}/$_maxQuoteLength자',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.metaLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 페이지 번호 카드
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          '페이지 번호',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.headingDark,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '페이지 번호를 입력하세요',
                        hintStyle: const TextStyle(
                          color: AppTheme.placeholder,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundCanvas,
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
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 중요 인용구 체크박스 카드
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
                    Checkbox(
                      value: _isImportant,
                      onChanged: (value) {
                        setState(() {
                          _isImportant = value ?? false;
                        });
                      },
                      activeColor: AppTheme.brandBlue,
                    ),
                    const SizedBox(width: 8),
                    const Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '중요 인용구로 표시',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.headingDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 미리보기 카드
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '미리보기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.headingDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCanvas,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _quoteController.text.trim().isEmpty
                          ? Text(
                              '인용구 내용이 여기에 표시됩니다...',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.placeholder,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : Text(
                              _quoteController.text,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.headingDark,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
                    const SizedBox(height: 100), // 하단 버튼 공간 확보
                  ],
                ),
              ),
            ),
            // 하단 액션 버튼
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.divider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (!_canSave())
                    Expanded(
                      child: Text(
                        '인용구 내용과 페이지 번호를 입력해 주세요',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.metaLight,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 16),
                  // 취소 버튼
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.borderSubtle),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 인용구 저장 버튼
                  ElevatedButton(
                    onPressed: (_canSave() && !_isSaving) ? _saveQuote : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandBlue,
                      disabledBackgroundColor: AppTheme.borderSubtle,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '인용구 저장',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


