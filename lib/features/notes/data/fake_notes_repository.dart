import 'package:one_note/features/notes/data/notes_repository.dart';
import 'package:one_note/features/notes/domain/note.dart';

class FakeNotesRepository implements NotesRepository {
  final List<Note> _notes = [];

  Future<List<Note>> getNotes() async => List.unmodifiable(_notes);

  @override
  Future<Note?> getNoteById(String id) async {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addNote(Note note) async {
    _notes.add(note);
  }

  @override
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<List<Note>> getNotesForUser(String userId) async {
    return _notes.where((n) => n.userId == userId).toList();
  }
}
