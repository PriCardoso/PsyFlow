import 'package:flutter_test/flutter_test.dart';
import 'package:psyflow_app/models/clinical_scale_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psyflow_app/core/services/clinical_scale_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('ClinicalScaleQuestion', () {
    test('creates question with all properties', () {
      const question = ClinicalScaleQuestion(
        id: 1,
        text: 'Test question',
        options: ['Option 1', 'Option 2'],
        optionValues: [0, 1],
      );

      expect(question.id, 1);
      expect(question.text, 'Test question');
      expect(question.options, ['Option 1', 'Option 2']);
      expect(question.optionValues, [0, 1]);
    });

    test('options and optionValues have same length', () {
      const question = ClinicalScaleQuestion(
        id: 1,
        text: 'Test',
        options: ['A', 'B', 'C'],
        optionValues: [0, 1, 2],
      );

      expect(question.options.length, question.optionValues.length);
    });
  });

  group('ClinicalScaleModel', () {
    late ClinicalScaleModel phq9Scale;
    late ClinicalScaleModel gad7Scale;
    late ClinicalScaleModel snapIvScale;

    setUp(() {
      final service = ClinicalScaleService(firestore: MockFirebaseFirestore());
      final all = service.getAllScales();
      phq9Scale = all.firstWhere((s) => s.code == 'PHQ-9');
      gad7Scale = all.firstWhere((s) => s.code == 'GAD-7');
      snapIvScale = all.firstWhere((s) => s.code == 'SNAP-IV');
    });

    test('PHQ-9 has correct properties', () {
      expect(phq9Scale.code, 'PHQ-9');
      expect(phq9Scale.category, ScaleCategory.depression);
      expect(phq9Scale.questions.length, 9);
    });

    test('GAD-7 has correct properties', () {
      expect(gad7Scale.code, 'GAD-7');
      expect(gad7Scale.category, ScaleCategory.anxiety);
      expect(gad7Scale.questions.length, 7);
    });

    test('SNAP-IV has correct properties', () {
      expect(snapIvScale.code, 'SNAP-IV');
      expect(snapIvScale.category, ScaleCategory.adhd);
      expect(snapIvScale.questions.length, 18);
    });

    test('all questions have valid optionValues', () {
      for (final scale in [phq9Scale, gad7Scale, snapIvScale]) {
        for (final question in scale.questions) {
          expect(question.optionValues.length, question.options.length);
          for (final value in question.optionValues) {
            expect(value, greaterThanOrEqualTo(0));
          }
        }
      }
    });
  });

  group('ClinicalScaleResponseModel', () {
    test('creates response with all properties', () {
      final response = ClinicalScaleResponseModel(
        id: 'resp1',
        scaleId: 'phq9',
        scaleCode: 'PHQ-9',
        patientId: 'patient1',
        professionalId: 'prof1',
        answers: {1: 2, 2: 1, 3: 0},
        totalScore: 3,
        severityInterpretation: 'Mínima',
        completedAt: DateTime(2024, 1, 15),
      );

      expect(response.id, 'resp1');
      expect(response.scaleCode, 'PHQ-9');
      expect(response.totalScore, 3);
      expect(response.severityInterpretation, 'Mínima');
    });

    test('fromMap parses answers correctly', () {
      final map = {
        'id': 'resp1',
        'scale_id': 'phq9',
        'scale_code': 'PHQ-9',
        'patient_id': 'patient1',
        'professional_id': 'prof1',
        'answers': {'1': 2, '2': 1, '3': 0},
        'total_score': 3,
        'severity_interpretation': 'Mínima',
        'completed_at': '2024-01-15T10:00:00.000Z',
      };

      final response = ClinicalScaleResponseModel.fromMap(map, 'resp1');

      expect(response.answers[1], 2);
      expect(response.answers[2], 1);
      expect(response.answers[3], 0);
    });

    test('toMap converts answers to string keys', () {
      final response = ClinicalScaleResponseModel(
        id: 'resp1',
        scaleId: 'phq9',
        scaleCode: 'PHQ-9',
        patientId: 'patient1',
        professionalId: 'prof1',
        answers: {1: 2, 2: 1},
        totalScore: 3,
        severityInterpretation: 'Mínima',
        completedAt: DateTime(2024, 1, 15),
      );

      final map = response.toMap();

      expect(map['answers']['1'], 2);
      expect(map['answers']['2'], 1);
    });
  });

  group('ScaleCategory', () {
    test('labels are in Portuguese', () {
      expect(ScaleCategory.depression.label, 'Depressão / Humor');
      expect(ScaleCategory.anxiety.label, 'Ansiedade');
      expect(ScaleCategory.adhd.label, 'Atenção & Hiperatividade (TDAH)');
      expect(ScaleCategory.occupationalRoutine.label, 'Rotina Ocupacional (TO)');
      expect(ScaleCategory.cognitiveDevelopment.label, 'Desenvolvimento Cognitivo');
      expect(ScaleCategory.general.label, 'Geral');
    });
  });
}