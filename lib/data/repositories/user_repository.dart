import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ikili_app/data/models/app_user_model.dart';

/// `users/{uid}` koleksiyonu. Kayıt/giriş sonrası profil bilgisini burada
/// tutar; History ve Profile ekranları buradan okur.
class UserRepository {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> upsertUser(AppUser user) {
    return _usersRef.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> updateDisplayName(String uid, String displayName) {
    return _usersRef.doc(uid).set(
      {'displayName': displayName},
      SetOptions(merge: true),
    );
  }
}
