import 'quote.dart';

class QuoteResponse {
  final bool success;
  final int status;
  final String message;
  final QuotePageData data;
  final String timestamp;

  QuoteResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    return QuoteResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: QuotePageData.fromJson(json['data']),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class QuotePageData {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<Quote> content;
  final int number;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  QuotePageData({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.content,
    required this.number,
    required this.first,
    required this.last,
    required this.numberOfElements,
    required this.empty,
  });

  factory QuotePageData.fromJson(Map<String, dynamic> json) {
    return QuotePageData(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      content: (json['content'] as List?)
              ?.map((e) => Quote.fromJson(e))
              .toList() ??
          [],
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}

