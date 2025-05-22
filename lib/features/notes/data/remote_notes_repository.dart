import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import 'notes_repository.dart';

/// Firebase Firestore kullanarak notları uzak (remote) olarak depolayan repository uygulaması.
class RemoteNotesRepository implements NotesRepository {
  final FirebaseFirestore firestore;
  static const String collectionName = 'notes';

  /// [FirebaseFirestore] örneği alarak yeni bir [RemoteNotesRepository] oluşturur.
  RemoteNotesRepository(this.firestore);

  /// Firestore'dan tüm notları getirir.
  @override
  Future<List<Note>> getNotes() async {
    final snapshot = await firestore.collection(collectionName).get();
    return snapshot.docs
        .map((doc) => Note.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

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
    await firestore.collection(collectionName).doc(note.id).set(note.toJson());
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
}

/// Uzak not repository'si örneği sağlayan Provider.
final remoteNotesRepositoryProvider = Provider<NotesRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return RemoteNotesRepository(firestore);
});
