// lib/models/statistics/statistics_response.dart

class StatisticsResponse {
  final bool success;
  final int status;
  final String message;
  final StatisticsData data;
  final String timestamp;

  StatisticsResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: StatisticsData.fromJson(json['data'] ?? {}),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class StatisticsData {
  final Summary summary;
  final List<MonthlyStat> monthly;
  final List<CategoryStat> category;

  StatisticsData({
    required this.summary,
    required this.monthly,
    required this.category,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      summary: Summary.fromJson(json['summary'] ?? {}),
      monthly: (json['monthly'] as List?)
              ?.map((e) => MonthlyStat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      category: (json['category'] as List?)
              ?.map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Summary {
  final int totalBooks;
  final int readBooks;
  final int totalPages;
  final int totalNotes;

  Summary({
    required this.totalBooks,
    required this.readBooks,
    required this.totalPages,
    required this.totalNotes,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalBooks: json['totalBooks'] ?? 0,
      readBooks: json['readBooks'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalNotes: json['totalNotes'] ?? 0,
    );
  }
}

class MonthlyStat {
  final String year;
  final String month;
  final int readCount;
  final int pageCount;
  final String label;

  MonthlyStat({
    required this.year,
    required this.month,
    required this.readCount,
    required this.pageCount,
    required this.label,
  });

  factory MonthlyStat.fromJson(Map<String, dynamic> json) {
    return MonthlyStat(
      year: json['year'] ?? '',
      month: json['month'] ?? '',
      readCount: json['readCount'] ?? 0,
      pageCount: json['pageCount'] ?? 0,
      label: json['label'] ?? '',
    );
  }
}

class CategoryStat {
  final String categoryCode;
  final String categoryName;
  final int count;

  CategoryStat({
    required this.categoryCode,
    required this.categoryName,
    required this.count,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      categoryCode: json['categoryCode'] ?? '',
      categoryName: json['categoryName'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

