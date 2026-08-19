import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';

class UserService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  UserService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  Future<void> saveProfile({
    required String role,
    required String fullName,
    String? phone,
    String? crp,
    String? bio,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await _db.collection('users').doc(user.uid).set({
        'id': user.uid,
        'email': user.email,
        'role': role,
        'full_name': fullName,
        'phone': phone,
        'crp': crp,
        'bio': bio,
        'profile_complete': true,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw AppException('Erro ao salvar perfil: $e', originalError: e);
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw AppException('Erro ao carregar perfil: $e', originalError: e);
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw AppException('Erro ao buscar usuário: $e', originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> listPsychologists() async {
    try {
      final snap = await _db
          .collection('users')
          .where('role', isEqualTo: 'psychologist')
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw AppException('Erro ao listar psicólogos: $e', originalError: e);
    }
  }
}
