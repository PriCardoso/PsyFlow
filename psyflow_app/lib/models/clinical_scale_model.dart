import 'package:cloud_firestore/cloud_firestore.dart';

enum ScaleCategory {
  depression,
  anxiety,
  adhd,
  occupationalRoutine,
  cognitiveDevelopment,
  general;

  String get label {
    switch (this) {
      case ScaleCategory.depression:
        return 'Depressão / Humor';
      case ScaleCategory.anxiety:
        return 'Ansiedade';
      case ScaleCategory.adhd:
        return 'Atenção & Hiperatividade (TDAH)';
      case ScaleCategory.occupationalRoutine:
        return 'Rotina Ocupacional (TO)';
      case ScaleCategory.cognitiveDevelopment:
        return 'Desenvolvimento Cognitivo';
      case ScaleCategory.general:
        return 'Geral';
    }
  }
}

class ClinicalScaleQuestion {
  final int id;
  final String text;
  final List<String> options; // Ex: ['Nenhuma vez', 'Vários dias', 'Mais da metade dos dias', 'Quase todos os dias']
  final List<int> optionValues; // Ex: [0, 1, 2, 3]

  const ClinicalScaleQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.optionValues,
  });
}

class ClinicalScaleModel {
  final String id;
  final String code; // Ex: PHQ-9, GAD-7, BDI-II, SNAP-IV
  final String title;
  final String description;
  final ScaleCategory category;
  final List<ClinicalScaleQuestion> questions;

  const ClinicalScaleModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
  });
}

class ClinicalScaleResponseModel {
  final String id;
  final String scaleId;
  final String scaleCode;
  final String patientId;
  final String professionalId;
  final Map<int, int> answers; // questionId -> selectedValue
  final int totalScore;
  final String severityInterpretation; // Ex: "Ansiedade Leve", "Sintomas Moderados de Depressão"
  final DateTime completedAt;

  const ClinicalScaleResponseModel({
    required this.id,
    required this.scaleId,
    required this.scaleCode,
    required this.patientId,
    required this.professionalId,
    required this.answers,
    required this.totalScore,
    required this.severityInterpretation,
    required this.completedAt,
  });

  factory ClinicalScaleResponseModel.fromMap(Map<String, dynamic> map, [String? id]) {
    final answersRaw = map['answers'] as Map<String, dynamic>? ?? {};
    final answersMap = <int, int>{};
    answersRaw.forEach((key, value) {
      final qId = int.tryParse(key);
      final val = value is int ? value : int.tryParse(value.toString()) ?? 0;
      if (qId != null) answersMap[qId] = val;
    });

    DateTime date;
    final comp = map['completed_at'];
    if (comp is Timestamp) {
      date = comp.toDate();
    } else if (comp is String) {
      date = DateTime.tryParse(comp) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    return ClinicalScaleResponseModel(
      id: id ?? map['id'] as String? ?? '',
      scaleId: map['scale_id'] ?? '',
      scaleCode: map['scale_code'] ?? '',
      patientId: map['patient_id'] ?? '',
      professionalId: map['professional_id'] ?? '',
      answers: answersMap,
      totalScore: map['total_score'] ?? 0,
      severityInterpretation: map['severity_interpretation'] ?? '',
      completedAt: date,
    );
  }

  Map<String, dynamic> toMap() {
    final answersConverted = <String, dynamic>{};
    answers.forEach((k, v) => answersConverted[k.toString()] = v);

    return {
      'scale_id': scaleId,
      'scale_code': scaleCode,
      'patient_id': patientId,
      'professional_id': professionalId,
      'answers': answersConverted,
      'total_score': totalScore,
      'severity_interpretation': severityInterpretation,
      'completed_at': Timestamp.fromDate(completedAt),
    };
  }
}
