import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';

class InitialAssessmentService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  InitialAssessmentService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _db = firestore,
        _auth = auth;

  User get _currentUser {
    final u = _auth.currentUser;
    if (u == null) throw AppException('Usuário não autenticado.');
    return u;
  }

  /// Paciente envia a ficha inicial pré-consulta
  Future<void> submitInitialAssessment({
    required String psychologistId,
    required String mainComplaint,
    required String symptomsDuration,
    required bool previousTherapy,
    String? previousTherapyDetails,
    required bool usingMedication,
    String? medicationDetails,
    required String mainGoal,
    int distressLevel = 5,
  }) async {
    final user = _currentUser;

    try {
      await _db.collection('initial_assessments').doc(user.uid).set({
        'patient_id': user.uid,
        'psychologist_id': psychologistId,
        'main_complaint': mainComplaint,
        'symptoms_duration': symptomsDuration,
        'previous_therapy': previousTherapy,
        'previous_therapy_details': previousTherapyDetails,
        'using_medication': usingMedication,
        'medication_details': medicationDetails,
        'main_goal': mainGoal,
        'distress_level': distressLevel,
        'created_at': FieldValue.serverTimestamp(),
        'is_completed': true,
      });
    } catch (e) {
      throw AppException('Erro ao salvar ficha de avaliação inicial: $e', originalError: e);
    }
  }

  /// Busca a avaliação inicial do paciente logado
  Future<Map<String, dynamic>?> getMyInitialAssessment() async {
    final user = _currentUser;

    try {
      final doc = await _db.collection('initial_assessments').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (_) {
      return null;
    }
  }

  /// Psicólogo busca a avaliação inicial de um paciente vinculado
  Future<Map<String, dynamic>?> getPatientInitialAssessment(String patientId) async {
    try {
      final doc = await _db.collection('initial_assessments').doc(patientId).get();
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (_) {
      return null;
    }
  }
}