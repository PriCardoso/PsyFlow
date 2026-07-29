// This file is part of the PsyFlow application
// Therapeutic Protocol Models

import 'package:cloud_firestore/cloud_firestore.dart';

class TherapeuticProtocol {
  final String id;
  final String name;
  final String description;
  final String specialty;
  final List<ProtocolStep> steps;
  final int estimatedWeeks;
  final List<String> targetConditions;
  final String difficultyLevel;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  const TherapeuticProtocol({
    required this.id,
    required this.name,
    required this.description,
    required this.specialty,
    required this.steps,
    required this.estimatedWeeks,
    required this.targetConditions,
    required this.difficultyLevel,
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  factory TherapeuticProtocol.fromMap(Map<String, dynamic> map, String id) {
    return TherapeuticProtocol(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      specialty: map['specialty'] ?? '',
      steps: (map['steps'] as List<dynamic>?)
              ?.map((e) => ProtocolStep.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      estimatedWeeks: map['estimated_weeks'] ?? map['estimatedWeeks'] ?? 4,
      targetConditions: List<String>.from(map['target_conditions'] ?? map['targetConditions'] ?? []),
      difficultyLevel: map['difficulty_level'] ?? map['difficultyLevel'] ?? 'beginner',
      isActive: map['is_active'] ?? map['isActive'] ?? true,
      createdAt: map['created_at'] is Timestamp
          ? (map['created_at'] as Timestamp).toDate()
          : map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
              : DateTime.now(),
      createdBy: map['created_by'] ?? map['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'specialty': specialty,
      'steps': steps.map((s) => s.toMap()).toList(),
      'estimated_weeks': estimatedWeeks,
      'target_conditions': targetConditions,
      'difficulty_level': difficultyLevel,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'created_by': createdBy,
    };
  }

  int get totalSteps => steps.length;
  int get totalInterventions => steps.fold(0, (sum, step) => sum + step.interventionIds.length);

  String get difficultyLabel {
    switch (difficultyLevel) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return difficultyLevel;
    }
  }

  Duration get estimatedDuration => Duration(days: estimatedWeeks * 7);
}

class ProtocolStep {
  final String id;
  final int order;
  final String title;
  final String description;
  final List<String> interventionIds;
  final int weekNumber;
  final List<String> objectives;
  final Map<String, dynamic> conditions;
  final bool isOptional;

  const ProtocolStep({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.interventionIds,
    required this.weekNumber,
    required this.objectives,
    this.conditions = const {},
    this.isOptional = false,
  });

  factory ProtocolStep.fromMap(Map<String, dynamic> map) {
    return ProtocolStep(
      id: map['id'] ?? '',
      order: map['order'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      interventionIds: List<String>.from(map['intervention_ids'] ?? map['interventionIds'] ?? []),
      weekNumber: map['week_number'] ?? map['weekNumber'] ?? 1,
      objectives: List<String>.from(map['objectives'] ?? []),
      conditions: Map<String, dynamic>.from(map['conditions'] ?? {}),
      isOptional: map['is_optional'] ?? map['isOptional'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order': order,
      'title': title,
      'description': description,
      'intervention_ids': interventionIds,
      'week_number': weekNumber,
      'objectives': objectives,
      'conditions': conditions,
      'is_optional': isOptional,
    };
  }
}

class PatientProtocolEnrollment {
  final String id;
  final String protocolId;
  final String patientId;
  final String professionalId;
  final int currentStepIndex;
  final List<StepProgress> stepProgress;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? nextStepUnlockAt;
  final EnrollmentStatus status;
  final Map<String, dynamic> adaptations;

  const PatientProtocolEnrollment({
    required this.id,
    required this.protocolId,
    required this.patientId,
    required this.professionalId,
    required this.currentStepIndex,
    required this.stepProgress,
    required this.startedAt,
    this.completedAt,
    this.nextStepUnlockAt,
    required this.status,
    this.adaptations = const {},
  });

  factory PatientProtocolEnrollment.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PatientProtocolEnrollment(
      id: id,
      protocolId: map['protocol_id'] ?? map['protocolId'] ?? '',
      patientId: map['patient_id'] ?? map['patientId'] ?? '',
      professionalId: map['professional_id'] ?? map['professionalId'] ?? '',
      currentStepIndex: map['current_step_index'] ?? map['currentStepIndex'] ?? 0,
      stepProgress: (map['step_progress'] as List<dynamic>?)
              ?.map((e) => StepProgress.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      startedAt: parseDate(map['started_at'] ?? map['startedAt']),
      completedAt: map['completed_at'] != null ? parseDate(map['completed_at']) : null,
      nextStepUnlockAt: map['next_step_unlock_at'] != null ? parseDate(map['next_step_unlock_at']) : null,
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'active'),
        orElse: () => EnrollmentStatus.active,
      ),
      adaptations: Map<String, dynamic>.from(map['adaptations'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'protocol_id': protocolId,
      'patient_id': patientId,
      'professional_id': professionalId,
      'current_step_index': currentStepIndex,
      'step_progress': stepProgress.map((s) => s.toMap()).toList(),
      'started_at': Timestamp.fromDate(startedAt),
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'next_step_unlock_at': nextStepUnlockAt != null ? Timestamp.fromDate(nextStepUnlockAt!) : null,
      'status': status.name,
      'adaptations': adaptations,
    };
  }

  double get progressPercent {
    if (stepProgress.isEmpty) return 0.0;
    final completed = stepProgress.where((s) => s.isCompleted).length;
    return completed / stepProgress.length;
  }

  StepProgress? getCurrentStep() {
    if (currentStepIndex >= 0 && currentStepIndex < stepProgress.length) {
      return stepProgress[currentStepIndex];
    }
    return null;
  }

  bool get isCompleted => status == EnrollmentStatus.completed;
  bool get isPaused => status == EnrollmentStatus.paused;
  bool get isActive => status == EnrollmentStatus.active;

  List<StepProgress> get availableSteps {
    return stepProgress.where((s) => s.status == StepStatus.available || s.status == StepStatus.inProgress).toList();
  }
}

class StepProgress {
  final String stepId;
  final int stepOrder;
  final StepStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> interventionResults;
  final int completionPercent;

  const StepProgress({
    required this.stepId,
    required this.stepOrder,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.interventionResults = const {},
    this.completionPercent = 0,
  });

  factory StepProgress.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return StepProgress(
      stepId: map['step_id'] ?? map['stepId'] ?? '',
      stepOrder: map['step_order'] ?? map['stepOrder'] ?? 0,
      status: StepStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'locked'),
        orElse: () => StepStatus.locked,
      ),
      startedAt: parseDate(map['started_at'] ?? map['startedAt']),
      completedAt: map['completed_at'] != null ? parseDate(map['completed_at']) : null,
      interventionResults: Map<String, dynamic>.from(map['intervention_results'] ?? map['interventionResults'] ?? {}),
      completionPercent: map['completion_percent'] ?? map['completionPercent'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'step_id': stepId,
      'step_order': stepOrder,
      'status': status.name,
      'started_at': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completed_at': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'intervention_results': interventionResults,
      'completion_percent': completionPercent,
    };
  }

  bool get isCompleted => status == StepStatus.completed;
  bool get isInProgress => status == StepStatus.inProgress;
  bool get isAvailable => status == StepStatus.available;
  bool get isLocked => status == StepStatus.locked;
}

enum EnrollmentStatus { active, paused, completed, cancelled }

enum StepStatus { locked, available, inProgress, completed, skipped }