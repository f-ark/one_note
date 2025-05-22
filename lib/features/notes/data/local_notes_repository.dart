import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/core/app_startup_provider/app_initializer_provider.dart';
import 'package:one_note/features/notes/data/notes_repository.dart';
import 'package:one_note/features/notes/domain/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences kullanarak notları yerel olarak depolayan repository uygulaması.
class LocalNotesRepository implements NotesRepository {
  static const String notesKey = 'notes';
  final SharedPreferences prefs;

  /// [SharedPreferences] örneği alarak yeni bir [LocalNotesRepository] oluşturur.
  LocalNotesRepository(this.prefs);

  /// SharedPreferences'tan tüm notları getirir.
  @override
  Future<List<Note>> getNotes() async {
    final jsonList = prefs.getStringList(notesKey) ?? [];
    return jsonList
        .map((json) => Note.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// SharedPreferences'tan belirli bir kimliğe sahip notu getirir.
  /// Eğer bulunamazsa null döndürür.
  @override
  Future<Note?> getNoteById(String id) async {
    final notes = await getNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Yeni bir notu SharedPreferences'a ekler.
  @override
  Future<void> addNote(Note note) async {
    final notes = await getNotes();
    notes.add(note);
    await _saveNotes(notes);
  }

  /// Varolan bir notu SharedPreferences'ta günceller.
  @override
  Future<void> updateNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await _saveNotes(notes);
    }
  }

  /// Belirli bir kimliğe sahip notu SharedPreferences'tan siler.
  @override
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.id == id);
    await _saveNotes(notes);
  }

  Future<void> _saveNotes(List<Note> notes) async {
    final jsonList = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(notesKey, jsonList);
  }
}

/// Yerel not repository'si örneği sağlayan Provider.
/// Bu provider, [SharedPreferences] hazır olduğunda LocalNotesRepository'yi oluşturur.
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final prefs = ref.read(sharedPreferencesProvider).requireValue;
  return LocalNotesRepository(prefs);
});
