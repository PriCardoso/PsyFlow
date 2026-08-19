import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/errors/app_exception.dart';

abstract class UserRepository {
  Future<UserModel?> getUserById(String uid);
  Future<void> createUserProfile(UserModel user);
  Future<void> updateUserProfile(UserModel user);
  Stream<UserModel?> streamUser(String uid);
}

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _db;

  FirestoreUserRepository({required FirebaseFirestore firestore})
      : _db = firestore;

  @override
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw AppException('Erro ao buscar usuário: $e', originalError: e);
    }
  }

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw AppException('Erro ao criar perfil: $e', originalError: e);
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      throw AppException('Erro ao atualizar perfil: $e', originalError: e);
    }
  }

  @override
  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }
}