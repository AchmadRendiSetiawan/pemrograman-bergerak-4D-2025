import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photographer.dart';

class PhotographerService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('photographers');

  // Baca data
  static Stream<List<Photographer>> getPhotographers() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Photographer.fromFirestore(doc)).toList());
  }

  // Tambah data
  static Future<String?> addPhotographer(Photographer photographer) async {
    try {
      final doc = _collection.doc();
      final newPhotographer = photographer.copyWith(id: doc.id);
      await doc.set(newPhotographer.toMap());
      return null;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Edit data
  static Future<String?> updatePhotographer(Photographer photographer) async {
    try {
      await _collection.doc(photographer.id).update(photographer.toMap());
      return null;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Hapus data
  static Future<String?> deletePhotographer(String id) async {
    try {
      await _collection.doc(id).delete();
      return null;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Tangani error supaya tidak melempar object (khusus untuk web)
  static String _handleError(Object e) {
    if (e is FirebaseException) {
      return e.message ?? 'Terjadi kesalahan Firebase';
    }
    return 'Terjadi kesalahan tak dikenal';
  }
}
