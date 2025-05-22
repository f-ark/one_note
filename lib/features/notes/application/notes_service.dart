import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/features/notes/data/notes_repository.dart';
import 'package:one_note/features/notes/domain/note.dart';

/// Notlarla ilgili iş mantığını ve repository erişimini yöneten servis sınıfı.
class NotesService {
  final Ref ref;

  /// [Ref] örneği alarak yeni bir [NotesService] oluşturur.
  NotesService(this.ref);

  /// Repository'den tüm notları getirir.
  Future<List<Note>> getNotes() async {
    final repo = ref.read(notesRepositoryProvider);
    return await repo.getNotes();
  }

  /// Yeni bir notu repository'e ekler.
  Future<void> addNote(Note note) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.addNote(note);
  }

  /// Varolan bir notu repository'de günceller.
  Future<void> updateNote(Note note) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.updateNote(note);
  }

  /// Belirli bir kimliğe sahip notu repository'den siler.
  Future<void> deleteNote(String id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.deleteNote(id);
  }
}

/// [NotesService] sağlayan Riverpod provider.
final notesServiceProvider = Provider<NotesService>((ref) => NotesService(ref));
