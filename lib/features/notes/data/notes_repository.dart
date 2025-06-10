import 'package:one_note/features/notes/domain/note.dart';

/// Notlar için veri kaynağı soyut sınıfı.
abstract class NotesRepository {
  /// Tüm notları getirir.
  /// Belirli bir kimliğe sahip notu getirir. Eğer bulunamazsa null döndürür.
  Future<Note?> getNoteById(String id);

  /// Belirli bir kullanıcının tüm notlarını getirir.
  Future<List<Note>> getNotesForUser(String userId);

  /// Yeni bir not ekler.
  Future<void> addNote(Note note);

  /// Varolan bir notu günceller.
  Future<void> updateNote(Note note);

  /// Belirli bir kimliğe sahip notu siler.
  Future<void> deleteNote(String id);
}
