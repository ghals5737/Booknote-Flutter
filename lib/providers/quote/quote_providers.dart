import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/quote_service.dart';
import '../../models/quote/quote.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) {
  return QuoteService();
});

final quotesForBookProvider = FutureProvider.family<List<Quote>, int>((ref, bookId) async {
  final quoteService = ref.watch(quoteServiceProvider);
  return quoteService.getQuotesForBook(bookId);
});

