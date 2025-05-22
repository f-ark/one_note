import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/features/notes/application/notes_service.dart';
import 'package:one_note/features/notes/domain/note.dart';

/// Notlarla ilgili UI durumunu ve işlemlerini yöneten controller.
class NotesController extends AsyncNotifier<FutureOr<void>> {
  /// Controller başlatıldığında çağrılır.
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  /// Notları yükler ve durumu günceller.
  Future<void> loadNotes() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notesServiceProvider).getNotes(),
    );
  }

  /// Yeni bir not ekler ve not listesini yeniden yükler.
  Future<void> addNote(Note note) async {
    await ref.read(notesServiceProvider).addNote(note);
    await loadNotes();
  }

  /// Varolan bir notu günceller ve not listesini yeniden yükler.
  Future<void> updateNote(Note note) async {
    await ref.read(notesServiceProvider).updateNote(note);
    await loadNotes();
  }

  /// Belirli bir kimliğe sahip notu siler ve not listesini yeniden yükler.
  Future<void> deleteNote(String id) async {
    await ref.read(notesServiceProvider).deleteNote(id);
    await loadNotes();
  }
}

/// Notlar için autoDispose özellikli [AsyncNotifier] provider.
final notesControllerProvider =
    AsyncNotifierProvider.autoDispose<NotesController, FutureOr<void>>(
      NotesController.new,
    );
