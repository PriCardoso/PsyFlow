import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyflow_app/models/clinical_scale_model.dart';

class ClinicalScaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Predefined clinical scales
  static final List<ClinicalScaleModel> _defaultScales = [
    // PHQ-9 - Depression
    ClinicalScaleModel(
      id: 'phq9',
      code: 'PHQ-9',
      title: 'Patient Health Questionnaire-9',
      description: 'Avaliação de sintomas depressivos nas últimas 2 semanas',
      category: ScaleCategory.depression,
      questions: [
        ClinicalScaleQuestion(id: 1, text: 'Pouco interesse ou prazer em fazer coisas', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 2, text: 'Sentir-se para baixo, deprimido ou sem esperança', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 3, text: 'Dificuldade para dormir ou dormir demais', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 4, text: 'Sentir-se cansado ou com pouca energia', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 5, text: 'Apetite pobre ou comer demais', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 6, text: 'Sentir-se mal sobre si mesmo', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 7, text: 'Dificuldade de concentração', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 8, text: 'Movimentar-se devagar ou agitado', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 9, text: 'Pensamentos de se machucar ou morrer', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
      ],
    ),
    // GAD-7 - Anxiety
    ClinicalScaleModel(
      id: 'gad7',
      code: 'GAD-7',
      title: 'Generalized Anxiety Disorder-7',
      description: 'Avaliação de sintomas de ansiedade generalizada nas últimas 2 semanas',
      category: ScaleCategory.anxiety,
      questions: [
        ClinicalScaleQuestion(id: 1, text: 'Sentir-se nervoso, ansioso ou no limite', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 2, text: 'Não conseguir parar ou controlar as preocupações', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 3, text: 'Preocupar-se demais com coisas diferentes', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 4, text: 'Dificuldade para relaxar', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 5, text: 'Ficar tão inquieto que é difícil ficar parado', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 6, text: 'Ficar facilmente irritado ou aborrecido', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 7, text: 'Sentir medo como se algo terrível fosse acontecer', options: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias'], optionValues: [0, 1, 2, 3]),
      ],
    ),
    // SNAP-IV - ADHD
    ClinicalScaleModel(
      id: 'snapiv',
      code: 'SNAP-IV',
      title: 'Swanson, Nolan and Pelham Rating Scale-IV',
      description: 'Avaliação de sintomas de TDAH (atenção, hiperatividade/impulsividade)',
      category: ScaleCategory.adhd,
      questions: [
        ClinicalScaleQuestion(id: 1, text: 'Falta de atenção a detalhes / erros por descuido', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 2, text: 'Dificuldade em manter a atenção em tarefas', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 3, text: 'Não parece ouvir quando falado diretamente', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 4, text: 'Não segue instruções / não termina tarefas', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 5, text: 'Dificuldade em organizar tarefas', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 6, text: 'Evita tarefas que exigem esforço mental sustentado', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 7, text: 'Perde coisas necessárias para tarefas', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 8, text: 'Distrai-se facilmente com estímulos externos', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 9, text: 'Esquecido nas atividades diárias', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 10, text: 'Mexe mãos/pés ou remexe-se na cadeira', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 11, text: 'Levanta-se quando se espera que permaneça sentado', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 12, text: 'Corre/sobe em situações inapropriadas', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 13, text: 'Dificuldade em brincar 조용히', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 14, text: 'Está sempre "a mil" / age como se tivesse motor', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 15, text: 'Fala excessivamente', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 16, text: 'Responde antes da pergunta ser completada', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 17, text: 'Dificuldade em aguardar a vez', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
        ClinicalScaleQuestion(id: 18, text: 'Interrompe ou intromete-se nos outros', options: ['Nunca', 'Às vezes', 'Frequentemente', 'Muito frequentemente'], optionValues: [0, 1, 2, 3]),
      ],
    ),
  ];

  List<ClinicalScaleModel> getAvailableScales() => _defaultScales;

  List<ClinicalScaleModel> getScalesByCategory(ScaleCategory category) {
    return _defaultScales.where((s) => s.category == category).toList();
  }

  ClinicalScaleModel? getScaleByCode(String code) {
    try {
      return _defaultScales.firstWhere((s) => s.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Submit a scale response
  Future<void> submitScaleResponse({
    required String scaleId,
    required String scaleCode,
    required String patientId,
    required String professionalId,
    required Map<int, int> answers,
    required int totalScore,
    required String severityInterpretation,
  }) async {
    await _db.collection('clinical_scale_responses').add({
      'scale_id': scaleId,
      'scale_code': scaleCode,
      'patient_id': patientId,
      'professional_id': professionalId,
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
      'total_score': totalScore,
      'severity_interpretation': severityInterpretation,
      'completed_at': FieldValue.serverTimestamp(),
    });
  }

  /// Get scale responses for a patient
  Future<List<ClinicalScaleResponseModel>> getPatientScaleResponses(String patientId) async {
    final snapshot = await _db
        .collection('clinical_scale_responses')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('completed_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ClinicalScaleResponseModel.fromMap({'id': doc.id, ...doc.data()}))
        .toList();
  }

  /// Get scale responses for a professional's patients
  Future<List<ClinicalScaleResponseModel>> getProfessionalScaleResponses(String professionalId) async {
    final snapshot = await _db
        .collection('clinical_scale_responses')
        .where('professional_id', isEqualTo: professionalId)
        .orderBy('completed_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ClinicalScaleResponseModel.fromMap({'id': doc.id, ...doc.data()}))
        .toList();
  }

  /// Get latest response for a specific scale and patient
  Future<ClinicalScaleResponseModel?> getLatestResponse({
    required String patientId,
    required String scaleCode,
  }) async {
    final snapshot = await _db
        .collection('clinical_scale_responses')
        .where('patient_id', isEqualTo: patientId)
        .where('scale_code', isEqualTo: scaleCode)
        .orderBy('completed_at', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ClinicalScaleResponseModel.fromMap({'id': snapshot.docs.first.id, ...snapshot.docs.first.data()});
  }

  /// Stream responses for real-time updates
  Stream<List<ClinicalScaleResponseModel>> streamPatientResponses(String patientId) {
    return _db
        .collection('clinical_scale_responses')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('completed_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClinicalScaleResponseModel.fromMap({'id': doc.id, ...doc.data()}))
            .toList());
  }

  /// Get all available clinical scales
  List<ClinicalScaleModel> getAllScales() {
    return _defaultScales;
  }
}