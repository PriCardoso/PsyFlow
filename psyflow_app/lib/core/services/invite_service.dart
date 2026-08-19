import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/patient_link_model.dart';
import '../../core/errors/app_exception.dart';

class InviteService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  InviteService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  /// Gera um código alfanumérico único de 6 caracteres
  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// Gera um convite e salva no Firestore
  Future<String> generateInvite() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final code = _generateCode();
      await _db.collection('invites').add({
        'psychologist_id': user.uid,
        'code': code,
        'used': false,
        'used_by': null,
        'expires_at': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'created_at': FieldValue.serverTimestamp(),
      });
      return code;
    } catch (e) {
      throw AppException('Erro ao gerar convite: $e', originalError: e);
    }
  }

  /// Lista todos os convites do psicólogo
  Future<List<Map<String, dynamic>>> getMyInvites() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('invites')
          .where('psychologist_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      throw AppException('Erro ao buscar convites: $e', originalError: e);
    }
  }

  /// Paciente usa o código para se vincular ao psicólogo
  Future<void> useInvite(String code) async {
    final patient = _auth.currentUser;
    if (patient == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('invites')
          .where('code', isEqualTo: code.toUpperCase().trim())
          .where('used', isEqualTo: false)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        throw AppException('Código inválido ou já utilizado.');
      }

      final inviteDoc = snap.docs.first;
      final invite = inviteDoc.data();

      final expiresAt = (invite['expires_at'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw AppException('Este código expirou. Peça um novo ao seu psicólogo.');
      }

      if (invite['psychologist_id'] == patient.uid) {
        throw AppException('Você não pode usar seu próprio convite.');
      }

      // Cria o vínculo em transação atômica
      await _db.runTransaction((tx) async {
        tx.set(_db.collection('links').doc(), {
          'psychologist_id': invite['psychologist_id'],
          'patient_id': patient.uid,
          'invite_id': inviteDoc.id,
          'active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
        tx.update(inviteDoc.reference, {
          'used': true,
          'used_by': patient.uid,
        });
      });
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Erro ao usar convite: $e', originalError: e);
    }
  }

  /// Lista pacientes vinculados ao psicólogo
  Future<List<PatientLink>> getMyPatients() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('links')
          .where('psychologist_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .get();

      final links = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();

      // Enriquecer com dados do paciente
      final enriched = await Future.wait(links.map((link) async {
        final patientDoc =
            await _db.collection('users').doc(link['patient_id']).get();
        if (patientDoc.exists) {
          link['patient'] = {'id': patientDoc.id, ...patientDoc.data()!};
        }
        return link;
      }));

      return enriched.map((m) => PatientLink.fromMap(m)).toList();
    } catch (e) {
      throw AppException('Erro ao buscar pacientes: $e', originalError: e);
    }
  }

  /// Desativa o vínculo com um paciente
  Future<void> deactivateLink(String linkId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await _db
          .collection('links')
          .doc(linkId)
          .update({'active': false});
    } catch (e) {
      throw AppException('Erro ao desvincular paciente: $e', originalError: e);
    }
  }

  /// Reativa o vínculo com um paciente
  Future<void> reactivateLink(String linkId) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await _db
          .collection('links')
          .doc(linkId)
          .update({'active': true});
    } catch (e) {
      throw AppException('Erro ao reativar vínculo: $e', originalError: e);
    }
  }

  /// Retorna o psicólogo vinculado ao paciente
  Future<Map<String, dynamic>?> getMyPsychologist() async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      final snap = await _db
          .collection('links')
          .where('patient_id', isEqualTo: user.uid)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final link = {'id': snap.docs.first.id, ...snap.docs.first.data()};

      final psychDoc =
          await _db.collection('users').doc(link['psychologist_id']).get();
      if (psychDoc.exists) {
        link['psychologist'] = {'id': psychDoc.id, ...psychDoc.data()!};
      }

      return link;
    } catch (e) {
      throw AppException('Erro ao buscar psicólogo: $e', originalError: e);
    }
  }
}