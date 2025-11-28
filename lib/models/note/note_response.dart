import 'note.dart';

class NoteResponse {
  final bool success;
  final int status;
  final String message;
  final NotePageData data;
  final String timestamp;

  NoteResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory NoteResponse.fromJson(Map<String, dynamic> json) {
    return NoteResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: NotePageData.fromJson(json['data']),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class NotePageData {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<Note> content;
  final int number;
  final bool first;
  final bool last;
  final int numberOfElements;
  final bool empty;

  NotePageData({
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

  factory NotePageData.fromJson(Map<String, dynamic> json) {
    return NotePageData(
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      content: (json['content'] as List?)
              ?.map((e) => Note.fromJson(e))
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

