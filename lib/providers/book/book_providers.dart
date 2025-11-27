import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/book_service.dart';
import '../../models/book/book.dart';

final bookServiceProvider = Provider<BookService>((ref) {
  return BookService();
});

final myLibraryBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getUserBooks();
});

final recentReadBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookService = ref.watch(bookServiceProvider);
  return bookService.getRecentReadBooks(7);
});