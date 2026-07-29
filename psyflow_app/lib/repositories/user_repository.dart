import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserById(String uid);
  Future<void> createUserProfile(UserModel user);
  Future<void> updateUserProfile(UserModel user);
  Stream<UserModel?> streamUser(String uid);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db;

  FirestoreUserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  @override
  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }
}
