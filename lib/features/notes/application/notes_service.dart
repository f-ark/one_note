import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/features/authentication/data/auth_repository.dart';
import 'package:one_note/features/notes/data/remote_notes_repository.dart';
import 'package:one_note/features/notes/domain/note.dart';

/// Notlarla ilgili iş mantığını ve repository erişimini yöneten servis sınıfı.
class NotesService {
  /// [Ref] örneği alarak yeni bir [NotesService] oluşturur.
  NotesService(this.ref);
  final Ref ref;

  /// Kullanıcı düzenlemeyi bitirdiğinde değişiklik varsa kaydeder.
  Future<void> saveIfChanged(
    String title,
    String content,
    String? noteId,
  ) async {
    final notesRepository = ref.read(notesRepositoryProvider);
    final authRepository = ref.read(authRepositoryProvider);
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return;
    if (noteId == null) {
      // yeni not ekle
      final userId = await authRepository.getCurrentUserId() ?? '';
      final note = Note(
        id: '', // id burada boş bırakılıyor, Firestore oluşturacak
        title: title.trim().isEmpty ? 'Başlıksız' : title.trim(),
        content: trimmedContent,
        createdAt: DateTime.now(),
        userId: userId,
      );
      await notesRepository.addNote(note);
      // Notlar güncellensin diye loadNotes controller'da çağrılacak
    } else {
      // mevcut notu güncelle
      final updated = Note(
        id: noteId,
        title: title.trim().isEmpty ? 'Başlıksız' : title.trim(),
        content: trimmedContent,
        createdAt: DateTime.now(),
        userId: await authRepository.getCurrentUserId() ?? '',
      );
      await notesRepository.updateNote(updated);
      // Notlar güncellensin diye loadNotes controller'da çağrılacak
    }
  }
}

/// [NotesService] sağlayan Riverpod provider.
final notesServiceProvider = Provider<NotesService>(NotesService.new);
