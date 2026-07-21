import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class PasswordResetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Opção nativa do Firebase — mais simples, sem código customizado:
  Future<void> sendNativeResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Fluxo customizado (mantém código de 6 dígitos):
  Future<String> createCode(String email) async {
    final rnd = Random.secure();
    final code = (100000 + rnd.nextInt(900000)).toString();

    await _db.collection('password_reset_codes').add({
      'email': email,
      'code': code,
      'used': false,
      'expires_at': Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 15)),
      ),
      'created_at': FieldValue.serverTimestamp(),
    });

    return code;
  }

  Future<bool> validateCode({
    required String email,
    required String code,
  }) async {
    final snap = await _db
        .collection('password_reset_codes')
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .where('used', isEqualTo: false)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return false;

    final expires =
        (snap.docs.first.data()['expires_at'] as Timestamp).toDate();
    return expires.isAfter(DateTime.now());
  }

  Future<void> markAsUsed(String email, String code) async {
    final snap = await _db
        .collection('password_reset_codes')
        .where('email', isEqualTo: email)
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    for (final doc in snap.docs) {
      await doc.reference.update({'used': true});
    }
  }
}