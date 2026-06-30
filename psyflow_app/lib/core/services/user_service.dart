import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveProfile({
    required String role,
    required String fullName,
    String? phone,
    String? crp,
    String? bio,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

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
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Erro ao carregar perfil: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
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
      throw Exception('Erro ao listar psicólogos: $e');
    }
  }
}
