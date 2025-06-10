import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/features/authentication/data/auth_repository.dart';
import 'package:one_note/features/notes/application/notes_service.dart';
import 'package:one_note/features/notes/data/remote_notes_repository.dart';
import 'package:one_note/features/notes/domain/note.dart';

/// Notlarla ilgili UI durumunu ve işlemlerini yöneten controller.
class NotesController extends AsyncNotifier<void> {
  bool _isSaving = false;
  @override
  FutureOr<void> build() {}

  /// Notları yükler ve durumu günceller.
  // Todo: Get isteklerini optimize et
  Future<void> loadNotes() async {
    final repo = ref.read(notesRepositoryProvider);
    final userId =
        await ref.read(authRepositoryProvider).getCurrentUserId() ?? '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => repo.getNotesForUser(userId));
  }

  /// Yeni bir not ekler ve not listesini yeniden yükler.
  Future<void> addNote(Note note) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.addNote(note);
    await loadNotes();
  }

  /// Varolan bir notu günceller ve not listesini yeniden yükler.
  Future<void> updateNote(Note note) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.updateNote(note);
    await loadNotes();
  }

  /// Belirli bir kimliğe sahip notu siler ve not listesini yeniden yükler.
  Future<void> deleteNote(String id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.deleteNote(id);
    await loadNotes();
  }

  /// Kullanıcı düzenlemeyi bitirdiğinde değişiklik varsa kaydeder.
  Future<void> saveIfChanged(
    String title,
    String content,
    String? noteId,
  ) async {
    state = const AsyncLoading();
    if (_isSaving) return;
    _isSaving = true;
    state = await AsyncValue.guard(
      () =>
          ref.read(notesServiceProvider).saveIfChanged(title, content, noteId),
    );
    _isSaving = false;
  }
}

/// Notlar için autoDispose özellikli [AsyncNotifier] provider.
final notesControllerProvider =
    AsyncNotifierProvider.autoDispose<NotesController, void>(
      NotesController.new,
    );
