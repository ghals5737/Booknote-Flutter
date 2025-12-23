import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/statistics_service.dart';
import '../../models/statistics/statistics_response.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});

final myStatisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return statisticsService.getMyStatistics();
});

