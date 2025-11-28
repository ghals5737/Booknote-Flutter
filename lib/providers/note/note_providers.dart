import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/note_service.dart';
import '../../models/note/note.dart';

final noteServiceProvider = Provider<NoteService>((ref) {
  return NoteService();
});

final notesForBookProvider = FutureProvider.family<List<Note>, int>((ref, bookId) async {
  final noteService = ref.watch(noteServiceProvider);
  return noteService.getNotesForBook(bookId);
});

