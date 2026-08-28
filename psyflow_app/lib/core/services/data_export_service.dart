import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../errors/app_exception.dart';

/// Serviço responsável por coletar e exportar os dados do usuário para conformidade LGPD / GDPR.
class DataExportService {
  final FirebaseFirestore _db;

  DataExportService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  /// Coleta todos os dados associados a um usuário e retorna uma estrutura padronizada
  Future<Map<String, dynamic>> collectUserData(String userId) async {
    try {
      final exportData = <String, dynamic>{
        'exported_at': DateTime.now().toIso8601String(),
        'platform': 'PsyFlow',
        'compliance': 'LGPD / GDPR Data Portability',
        'user_id': userId,
      };

      // 1. Dados cadastrais
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        exportData['profile'] = userDoc.data();
      }

      // 2. Registros de humor
      try {
        final moodSnap = await _db
            .collection('mood_entries')
            .where('user_id', isEqualTo: userId)
            .get();
        exportData['mood_entries'] =
            moodSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } catch (_) {
        exportData['mood_entries'] = [];
      }

      // 3. Tarefas terapêuticas
      try {
        final tasksSnap = await _db
            .collection('tasks')
            .where('patient_id', isEqualTo: userId)
            .get();
        exportData['tasks'] =
            tasksSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } catch (_) {
        exportData['tasks'] = [];
      }

      // 4. Consultas / Agendamentos
      try {
        final appSnap = await _db
            .collection('appointments')
            .where('patient_id', isEqualTo: userId)
            .get();
        exportData['appointments'] =
            appSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } catch (_) {
        exportData['appointments'] = [];
      }

      // 5. Respostas de Escalas Clínicas
      try {
        final scalesSnap = await _db
            .collection('clinical_scale_responses')
            .where('user_id', isEqualTo: userId)
            .get();
        exportData['clinical_scale_responses'] =
            scalesSnap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      } catch (_) {
        exportData['clinical_scale_responses'] = [];
      }

      return exportData;
    } catch (e) {
      throw AppException('Falha ao exportar dados do usuário: $e', originalError: e);
    }
  }

  /// Retorna o JSON formatado pronto para download/compartilhamento
  Future<String> exportUserDataAsFormattedJson(String userId) async {
    final data = await collectUserData(userId);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}
