import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicalSessionModel {
  final String id;
  final String professionalId;
  final String patientId;
  final DateTime sessionDate;
  final String summary; // Resumo da sessão
  final String clinicalNotes; // Anotações clínicas privativas do profissional
  final List<String> goalsAddressed; // Objetivos/Metas trabalhadas
  final List<String> interventionsUsed; // Intervenções/Atividades aplicadas
  final String? patientMoodObserved; // Observação do estado emocional pelo profissional
  final String? nextSteps; // Próximos passos / Tarefas combinadas
  final DateTime createdAt;

  const ClinicalSessionModel({
    required this.id,
    required this.professionalId,
    required this.patientId,
    required this.sessionDate,
    required this.summary,
    required this.clinicalNotes,
    required this.goalsAddressed,
    required this.interventionsUsed,
    required this.createdAt,
    this.patientMoodObserved,
    this.nextSteps,
  });

  factory ClinicalSessionModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ClinicalSessionModel(
      id: id,
      professionalId: map['professional_id'] ?? map['psychologist_id'] ?? '',
      patientId: map['patient_id'] ?? '',
      sessionDate: parseDate(map['session_date'] ?? map['date']),
      summary: map['summary'] ?? '',
      clinicalNotes: map['clinical_notes'] ?? map['notes'] ?? '',
      goalsAddressed: List<String>.from(map['goals_addressed'] ?? []),
      interventionsUsed: List<String>.from(map['interventions_used'] ?? []),
      patientMoodObserved: map['patient_mood_observed'],
      nextSteps: map['next_steps'],
      createdAt: parseDate(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'professional_id': professionalId,
      'patient_id': patientId,
      'session_date': Timestamp.fromDate(sessionDate),
      'summary': summary,
      'clinical_notes': clinicalNotes,
      'goals_addressed': goalsAddressed,
      'interventions_used': interventionsUsed,
      'patient_mood_observed': patientMoodObserved,
      'next_steps': nextSteps,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
