import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_note/features/notes/data/notes_repository.dart';
import 'package:one_note/features/notes/domain/note.dart';

/// Firebase Firestore kullanarak notları uzaklarak depolayan repository.
class RemoteNotesRepository implements NotesRepository {
  /// [FirebaseFirestore] örneği alarak yeni bir [RemoteNotesRepository] .
  RemoteNotesRepository(this.firestore);
  final FirebaseFirestore firestore;
  static const String collectionName = 'notes';

  /// Firestore'dan belirli bir kimliğe sahip notu getirir.
  /// Eğer bulunamazsa null döndürür.
  @override
  Future<Note?> getNoteById(String id) async {
    
    final doc = await firestore.collection(collectionName).doc(id).get();
    if (doc.exists) {
      return Note.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  /// Yeni bir notu Firestore'a ekler.
  @override
  Future<void> addNote(Note note) async {
    await firestore.collection(collectionName).add(note.toJson()..remove('id'));
  }

  /// Varolan bir notu Firestore'da günceller.
  @override
  Future<void> updateNote(Note note) async {
    await firestore
        .collection(collectionName)
        .doc(note.id)
        .update(note.toJson());
  }

  /// Belirli bir kimliğe sahip notu Firestore'dan siler.
  @override
  Future<void> deleteNote(String id) async {
    await firestore.collection(collectionName).doc(id).delete();
  }

  @override
  Future<List<Note>> getNotesForUser(String userId) async {
    final snapshot =
        await firestore
            .collection(collectionName)
            .where('userId', isEqualTo: userId)
            .get();
    return snapshot.docs
        .map((doc) => Note.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}

/// Uzak not repository'si örneği sağlayan Provider.
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return RemoteNotesRepository(firestore);
});
