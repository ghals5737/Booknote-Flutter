import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/search_service.dart';
import '../../models/search/unified_search_response.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

final unifiedSearchProvider = FutureProvider.family<UnifiedSearchData, UnifiedSearchParams>((ref, params) async {
  final searchService = ref.watch(searchServiceProvider);
  return searchService.unifiedSearch(
    query: params.query,
    type: params.type,
    page: params.page,
    size: params.size,
  );
});

class UnifiedSearchParams {
  final String query;
  final String type;
  final int page;
  final int size;

  UnifiedSearchParams({
    required this.query,
    this.type = 'all',
    this.page = 1,
    this.size = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnifiedSearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          type == other.type &&
          page == other.page &&
          size == other.size;

  @override
  int get hashCode => query.hashCode ^ type.hashCode ^ page.hashCode ^ size.hashCode;
}

