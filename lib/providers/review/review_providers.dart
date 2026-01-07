
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/review_service.dart';
import '../../models/review/review_models.dart';

// ReviewService 인스턴스를 제공하는 Provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

// 오늘의 복습 데이터를 가져오는 FutureProvider
final todayReviewProvider = FutureProvider<TodayReviewData>((ref) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getTodayReviews();
});

// 복습 항목 완료 상태를 관리하는 StateNotifier
class ReviewCompleter extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ReviewCompleter(this.ref) : super(const AsyncValue.data(null));

  Future<void> complete(
    int reviewId,
    int reviewItemId,
    String responseType,
  ) async {
    state = const AsyncValue.loading();
    try {
      final reviewService = ref.read(reviewServiceProvider);
      await reviewService.completeReviewItem(reviewId, reviewItemId, responseType);
      state = const AsyncValue.data(null);
      // 완료 후 오늘의 복습 목록을 새로고침
      ref.invalidate(todayReviewProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// ReviewCompleter의 인스턴스를 제공하는 StateNotifierProvider
final reviewCompleterProvider = StateNotifierProvider<ReviewCompleter, AsyncValue<void>>((ref) {
  return ReviewCompleter(ref);
});

// 복습 기록 데이터를 가져오는 FutureProvider
final reviewHistoryProvider = FutureProvider<ReviewHistoryPageData>((ref) async {
  final reviewService = ref.watch(reviewServiceProvider);
  return reviewService.getReviewHistory(page: 0, size: 100);
});
