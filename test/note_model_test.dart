import 'package:flutter_test/flutter_test.dart';
import 'package:one_note/features/notes/domain/note.dart';

void main() {
  group('Note Model', () {
    final now = DateTime.now();
    final note = Note(
      id: '1',
      title: 'Başlık',
      content: 'İçerik',
      createdAt: now,
      userId: 'user1',
    );

    test('toJson ve fromJson', () {
      final json = note.toJson();
      final from = Note.fromJson({...json, 'createdAt': now.toIso8601String()});
      expect(from, note);
    });

    test('copyWith', () {
      final copy = note.copyWith(title: 'Yeni Başlık');
      expect(copy.title, 'Yeni Başlık');
      expect(copy.content, note.content);
    });

    test('eşitlik', () {
      final note2 = Note(
        id: '1',
        title: 'Başlık',
        content: 'İçerik',
        createdAt: now,
        userId: 'user1',
      );
      expect(note, note2);
      expect(note.hashCode, note2.hashCode);
    });
  });
}
