import '../domain/note.dart';

/// Notlar için veri kaynağı soyut sınıfı.
abstract class NotesRepository {
  /// Tüm notları getirir.
  Future<List<Note>> getNotes();

  /// Belirli bir kimliğe sahip notu getirir. Eğer bulunamazsa null döndürür.
  Future<Note?> getNoteById(String id);

  /// Yeni bir not ekler.
  Future<void> addNote(Note note);

  /// Varolan bir notu günceller.
  Future<void> updateNote(Note note);

  /// Belirli bir kimliğe sahip notu siler.
  Future<void> deleteNote(String id);
}
