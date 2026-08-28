import 'package:flutter_test/flutter_test.dart';
import 'package:psyflow_app/core/services/clinical_scale_service.dart';
import 'package:psyflow_app/models/clinical_scale_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('ClinicalScaleService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ClinicalScaleService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = ClinicalScaleService(firestore: fakeFirestore);
    });

    test('getAvailableScales returns PHQ-9, GAD-7 and SNAP-IV', () {
      final scales = service.getAvailableScales();
      expect(scales.length, 3);
      expect(scales.map((s) => s.code), containsAll(['PHQ-9', 'GAD-7', 'SNAP-IV']));
    });

    test('getScalesByCategory filters scales correctly', () {
      final depressionScales = service.getScalesByCategory(ScaleCategory.depression);
      expect(depressionScales.length, 1);
      expect(depressionScales.first.code, 'PHQ-9');

      final anxietyScales = service.getScalesByCategory(ScaleCategory.anxiety);
      expect(anxietyScales.length, 1);
      expect(anxietyScales.first.code, 'GAD-7');

      final adhdScales = service.getScalesByCategory(ScaleCategory.adhd);
      expect(adhdScales.length, 1);
      expect(adhdScales.first.code, 'SNAP-IV');
    });

    test('getScaleByCode returns correct scale or null if not found', () {
      final phq9 = service.getScaleByCode('PHQ-9');
      expect(phq9, isNotNull);
      expect(phq9?.title, 'Patient Health Questionnaire-9');

      final notFound = service.getScaleByCode('NON_EXISTING');
      expect(notFound, isNull);
    });

    test('submitScaleResponse writes response and getPatientScaleResponses retrieves it', () async {
      await service.submitScaleResponse(
        scaleId: 'phq9',
        scaleCode: 'PHQ-9',
        patientId: 'patient-42',
        professionalId: 'doc-1',
        answers: {1: 2, 2: 3, 3: 1},
        totalScore: 6,
        severityInterpretation: 'Leve',
      );

      final responses = await service.getPatientScaleResponses('patient-42');
      expect(responses.length, 1);
      expect(responses.first.scaleCode, 'PHQ-9');
      expect(responses.first.totalScore, 6);
      expect(responses.first.severityInterpretation, 'Leve');
    });
  });
}