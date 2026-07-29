import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyflow_app/models/therapeutic_protocol.dart';
import 'package:psyflow_app/models/intervention_template.dart';

class ProtocolService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all active protocols
  Future<List<TherapeuticProtocol>> getActiveProtocols({String? specialty}) async {
    Query query = _db.collection('therapeutic_protocols').where('is_active', isEqualTo: true);
    if (specialty != null) {
      query = query.where('specialty', isEqualTo: specialty);
    }
    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((doc) => TherapeuticProtocol.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  /// Get protocol by ID
  Future<TherapeuticProtocol?> getProtocolById(String protocolId) async {
    final doc = await _db.collection('therapeutic_protocols').doc(protocolId).get();
    if (!doc.exists) return null;
    return TherapeuticProtocol.fromMap(doc.data()!, doc.id);
  }

  /// Create a new protocol
  Future<String> createProtocol(TherapeuticProtocol protocol) async {
    final docRef = await _db.collection('therapeutic_protocols').add(protocol.toMap());
    return docRef.id;
  }

  /// Enroll patient in a protocol
  Future<String> enrollPatient({
    required String protocolId,
    required String patientId,
    required String professionalId,
  }) async {
    final protocol = await getProtocolById(protocolId);
    if (protocol == null) throw Exception('Protocolo não encontrado');

    final stepProgress = protocol.steps.map((step) => StepProgress(
      stepId: step.id,
      stepOrder: step.order,
      status: step.order == 1 ? StepStatus.available : StepStatus.locked,
    )).toList();

    final enrollment = PatientProtocolEnrollment(
      id: '',
      protocolId: protocolId,
      patientId: patientId,
      professionalId: professionalId,
      currentStepIndex: 0,
      stepProgress: stepProgress,
      startedAt: DateTime.now(),
      status: EnrollmentStatus.active,
    );

    final docRef = await _db.collection('protocol_enrollments').add(enrollment.toMap());
    return docRef.id;
  }

  /// Get patient's protocol enrollments
  Future<List<PatientProtocolEnrollment>> getPatientEnrollments(String patientId) async {
    final snapshot = await _db
        .collection('protocol_enrollments')
        .where('patient_id', isEqualTo: patientId)
        .orderBy('started_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => PatientProtocolEnrollment.fromMap(doc.data(), doc.id)).toList();
  }

  /// Get professional's protocol enrollments
  Future<List<PatientProtocolEnrollment>> getProfessionalEnrollments(String professionalId) async {
    final snapshot = await _db
        .collection('protocol_enrollments')
        .where('professional_id', isEqualTo: professionalId)
        .orderBy('started_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => PatientProtocolEnrollment.fromMap(doc.data(), doc.id)).toList();
  }

  /// Get enrollment by ID
  Future<PatientProtocolEnrollment?> getEnrollmentById(String enrollmentId) async {
    final doc = await _db.collection('protocol_enrollments').doc(enrollmentId).get();
    if (!doc.exists) return null;
    return PatientProtocolEnrollment.fromMap(doc.data()!, doc.id);
  }

  /// Update step progress
  Future<void> updateStepProgress({
    required String enrollmentId,
    required int stepIndex,
    required StepProgress progress,
  }) async {
    final enrollment = await getEnrollmentById(enrollmentId);
    if (enrollment == null) throw Exception('Matrícula não encontrada');

    final updatedProgress = List<StepProgress>.from(enrollment.stepProgress);
    if (stepIndex >= 0 && stepIndex < updatedProgress.length) {
      updatedProgress[stepIndex] = progress;
    }

    // Check if we should unlock next step
    int newCurrentIndex = enrollment.currentStepIndex;
    DateTime? nextUnlockAt;

    if (progress.isCompleted && stepIndex < updatedProgress.length - 1) {
      // Unlock next step
      final nextStep = updatedProgress[stepIndex + 1];
      if (nextStep.isLocked) {
        updatedProgress[stepIndex + 1] = StepProgress(
          stepId: nextStep.stepId,
          stepOrder: nextStep.stepOrder,
          status: StepStatus.available,
          startedAt: DateTime.now(),
        );
        newCurrentIndex = stepIndex + 1;
      }
    }

    // Check if protocol is completed
    EnrollmentStatus newStatus = enrollment.status;
    DateTime? completedAt;
    if (updatedProgress.every((s) => s.isCompleted || s.isLocked)) {
      newStatus = EnrollmentStatus.completed;
      completedAt = DateTime.now();
    }

    await _db.collection('protocol_enrollments').doc(enrollmentId).update({
      'current_step_index': newCurrentIndex,
      'step_progress': updatedProgress.map((s) => s.toMap()).toList(),
      'status': newStatus.name,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt) : null,
      'next_step_unlock_at': nextUnlockAt != null ? Timestamp.fromDate(nextUnlockAt) : null,
    });
  }

  /// Record intervention completion in a step
  Future<void> recordInterventionResult({
    required String enrollmentId,
    required int stepIndex,
    required String interventionId,
    required Map<String, dynamic> result,
  }) async {
    final enrollment = await getEnrollmentById(enrollmentId);
    if (enrollment == null) throw Exception('Matrícula não encontrada');

    final updatedProgress = List<StepProgress>.from(enrollment.stepProgress);
    if (stepIndex >= 0 && stepIndex < updatedProgress.length) {
      final step = updatedProgress[stepIndex];
      final newResults = Map<String, dynamic>.from(step.interventionResults);
      newResults[interventionId] = {
        ...result,
        'completed_at': FieldValue.serverTimestamp(),
      };

      // Calculate completion percent based on interventions in this step
      final protocol = await getProtocolById(enrollment.protocolId);
      if (protocol != null && stepIndex < protocol.steps.length) {
        final protocolStep = protocol.steps[stepIndex];
        final totalInterventions = protocolStep.interventionIds.length;
        final completedInterventions = newResults.keys.length;
        final percent = totalInterventions > 0 ? (completedInterventions / totalInterventions * 100).round() : 0;

        updatedProgress[stepIndex] = StepProgress(
          stepId: step.stepId,
          stepOrder: step.stepOrder,
          status: step.status,
          startedAt: step.startedAt,
          completedAt: step.completedAt,
          interventionResults: newResults,
          completionPercent: percent,
        );

        // If all interventions completed, mark step as completed
        if (completedInterventions >= totalInterventions) {
          updatedProgress[stepIndex] = StepProgress(
            stepId: step.stepId,
            stepOrder: step.stepOrder,
            status: StepStatus.completed,
            startedAt: step.startedAt,
            completedAt: DateTime.now(),
            interventionResults: newResults,
            completionPercent: 100,
          );
        }
      }
    }

    await _db.collection('protocol_enrollments').doc(enrollmentId).update({
      'step_progress': updatedProgress.map((s) => s.toMap()).toList(),
    });
  }

  /// Adapt protocol based on patient progress (AI-assisted)
  Future<void> adaptProtocol({
    required String enrollmentId,
    required Map<String, dynamic> adaptations,
  }) async {
    await _db.collection('protocol_enrollments').doc(enrollmentId).update({
      'adaptations': adaptations,
    });
  }

  /// Pause enrollment
  Future<void> pauseEnrollment(String enrollmentId) async {
    await _db.collection('protocol_enrollments').doc(enrollmentId).update({
      'status': EnrollmentStatus.paused.name,
    });
  }

  /// Resume enrollment
  Future<void> resumeEnrollment(String enrollmentId) async {
    await _db.collection('protocol_enrollments').doc(enrollmentId).update({
      'status': EnrollmentStatus.active.name,
    });
  }

  /// Cancel enrollment
  Future<void> cancelEnrollment(String enrollmentId) async {
    await _db.collection('protocol_enrollments').doc(enrollmentId).update({
      'status': EnrollmentStatus.cancelled.name,
    });
  }

  /// Stream enrollment for real-time updates
  Stream<PatientProtocolEnrollment?> streamEnrollment(String enrollmentId) {
    return _db.collection('protocol_enrollments').doc(enrollmentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PatientProtocolEnrollment.fromMap(doc.data()!, doc.id);
    });
  }

  /// Get default protocols for each specialty
  static List<TherapeuticProtocol> getDefaultProtocols() {
    return [
      // CBT Emotional Regulation Protocol
      TherapeuticProtocol(
        id: 'cbt_emotional_regulation',
        name: 'Protocolo de Regulação Emocional (TCC)',
        description: 'Protocolo de 4 semanas baseado em Terapia Cognitivo-Comportamental para regulação emocional',
        specialty: 'psychology',
        estimatedWeeks: 4,
        targetConditions: ['ansiedade', 'depressão', 'estresse', 'dificuldade emocional'],
        difficultyLevel: 'beginner',
        createdAt: DateTime.now(),
        createdBy: 'system',
        steps: [
          ProtocolStep(
            id: 'step1',
            order: 1,
            title: 'Psicoeducação e Monitoramento',
            description: 'Entender emoções e iniciar monitoramento do humor',
            interventionIds: ['mood_tracking_intro', 'psychoeducation_emotions'],
            weekNumber: 1,
            objectives: ['Identificar emoções primárias', 'Iniciar diário de humor', 'Entender o modelo cognitivo'],
          ),
          ProtocolStep(
            id: 'step2',
            order: 2,
            title: 'Identificação de Pensamentos Automáticos',
            description: 'Aprender a capturar e registrar pensamentos automáticos',
            interventionIds: ['thought_record_basic', 'cognitive_triangle'],
            weekNumber: 2,
            objectives: ['Reconhecer pensamentos automáticos', 'Preencher registro de pensamentos', 'Identificar distorções cognitivas'],
          ),
          ProtocolStep(
            id: 'step3',
            order: 3,
            title: 'Questionamento e Reestruturação',
            description: 'Desenvolver habilidades de questionamento socrático',
            interventionIds: ['socratic_questioning', 'cognitive_restructuring'],
            weekNumber: 3,
            objectives: ['Aplicar questionamento socrático', 'Gerar pensamentos alternativos', 'Testar evidências'],
          ),
          ProtocolStep(
            id: 'step4',
            order: 4,
            title: 'Prevenção de Recaída e Consolidação',
            description: 'Consolidar aprendizados e criar plano de manutenção',
            interventionIds: ['relapse_prevention_plan', 'skill_consolidation'],
            weekNumber: 4,
            objectives: ['Criar plano de prevenção', 'Consolidar ferramentas aprendidas', 'Agendar follow-up'],
          ),
        ],
      ),
      // Occupational Therapy Sensory Integration Protocol
      TherapeuticProtocol(
        id: 'ot_sensory_integration',
        name: 'Protocolo de Integração Sensorial (TO)',
        description: 'Protocolo de 6 semanas para regulação sensorial e participação ocupacional',
        specialty: 'occupational_therapy',
        estimatedWeeks: 6,
        targetConditions: ['processamento sensorial', 'regulação', 'participação ocupacional'],
        difficultyLevel: 'intermediate',
        createdAt: DateTime.now(),
        createdBy: 'system',
        steps: [
          ProtocolStep(
            id: 'step1',
            order: 1,
            title: 'Avaliação do Perfil Sensorial',
            description: 'Identificar padrões de processamento sensorial',
            interventionIds: ['sensory_profile_assessment', 'sensory_diet_intro'],
            weekNumber: 1,
            objectives: ['Completar perfil sensorial', 'Identificar sensibilidades', 'Criar dieta sensorial inicial'],
          ),
          ProtocolStep(
            id: 'step2',
            order: 2,
            title: 'Regulação Proprioceptiva',
            description: 'Atividades de trabalho pesado e pressão profunda',
            interventionIds: ['heavy_work_activities', 'deep_pressure_techniques'],
            weekNumber: 2,
            objectives: ['Praticar trabalho pesado', 'Usar pressão profunda', 'Observar efeitos na regulação'],
          ),
          ProtocolStep(
            id: 'step3',
            order: 3,
            title: 'Modulação Vestibular',
            description: 'Atividades de movimento controlado',
            interventionIds: ['vestibular_activities', 'movement_breaks'],
            weekNumber: 3,
            objectives: ['Explorar movimento linear', 'Praticar pausas de movimento', 'Integrar na rotina'],
          ),
          ProtocolStep(
            id: 'step4',
            order: 4,
            title: 'Discriminação Tátil e Oral',
            description: 'Exposição gradual a texturas e input oral',
            interventionIds: ['tactile_discrimination', 'oral_motor_activities'],
            weekNumber: 4,
            objectives: ['Tolerar diferentes texturas', 'Fortalecer motricidade oral', 'Reduzir defensividade'],
          ),
          ProtocolStep(
            id: 'step5',
            order: 5,
            title: 'Integração na Rotina Ocupacional',
            description: 'Aplicar estratégias sensoriais nas AVDs',
            interventionIds: ['adl_sensory_strategies', 'environmental_modifications'],
            weekNumber: 5,
            objectives: ['Adaptar rotinas de cuidado pessoal', 'Modificar ambiente', 'Generalizar habilidades'],
          ),
          ProtocolStep(
            id: 'step6',
            order: 6,
            title: 'Autonomia e Plano de Manutenção',
            description: 'Desenvolver independência no uso de estratégias',
            interventionIds: ['self_regulation_toolkit', 'maintenance_plan'],
            weekNumber: 6,
            objectives: ['Criar kit de autorregulação', 'Ensinar auto-monitoramento', 'Planejar continuidade'],
          ),
        ],
      ),
    ];
  }
}