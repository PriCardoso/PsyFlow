import 'package:flutter_test/flutter_test.dart';
import 'package:psyflow_app/models/user_model.dart';
import 'package:psyflow_app/core/services/intervention_engine.dart';
import 'package:psyflow_app/core/services/clinical_ai_service.dart';

void main() {
  group('UserModel Unit Tests', () {
    test('Should parse UserModel correctly with full_name legacy key', () {
      final map = {
        'email': 'terapeuta@psyflow.com',
        'full_name': 'Dra. Ana Silva',
        'role': 'professional',
        'specialty': 'occupational_therapy',
        'professional_registration': 'CREFITO-12345',
        'active': true,
      };

      final user = UserModel.fromMap(map, 'user_123');

      expect(user.uid, equals('user_123'));
      expect(user.fullName, equals('Dra. Ana Silva'));
      expect(user.role, equals(UserRole.professional));
      expect(user.specialty, equals(ProfessionalSpecialty.occupationalTherapy));
      expect(user.isProfessional, isTrue);
      expect(user.isPatient, isFalse);
    });

    test('Should serialize UserModel back to map accurately', () {
      final user = UserModel(
        uid: 'u1',
        email: 'paciente@psyflow.com',
        fullName: 'Carlos Andrade',
        role: UserRole.patient,
        createdAt: DateTime(2026, 1, 1),
      );

      final map = user.toMap();

      expect(map['full_name'], equals('Carlos Andrade'));
      expect(map['fullName'], equals('Carlos Andrade'));
      expect(map['role'], equals('patient'));
    });
  });

  group('InterventionEngine Unit Tests (Fase 5)', () {
    const engine = InterventionEngine();

    test('Should recommend sensory tasks for low mood in Occupational Therapy', () {
      final recs = engine.recommendInterventionsForMood(
        averageMoodScore: 2,
        specialty: ProfessionalSpecialty.occupationalTherapy,
      );

      expect(recs, isNotEmpty);
      expect(recs.first.specialty, equals(ProfessionalSpecialty.occupationalTherapy));
      expect(recs.first.category, contains('Sensorial'));
    });

    test('Should recommend grounding and TCC tasks for Psychology', () {
      final recs = engine.recommendInterventionsForMood(
        averageMoodScore: 1,
        specialty: ProfessionalSpecialty.psychology,
      );

      expect(recs.length, greaterThanOrEqualTo(2));
      expect(recs.any((r) => r.title.contains('Grounding')), isTrue);
    });
  });

  group('ClinicalAIService Unit Tests (Fase 6)', () {
    final aiService = ClinicalAIService();

    test('Should generate warning recommendation on low adherence', () {
      final recs = aiService.generate(
        adherence: 35.0,
        moodAverage: 4.0,
        completedTasks: 2,
      );

      expect(recs.any((r) => r.severity == 'warning'), isTrue);
    });

    test('Should draft formatted clinical session summary', () {
      final summary = aiService.generateSessionSummary(
        rawNotes: 'Paciente relatou melhoria na qualidade do sono após treino de higiene do sono.',
        patientName: 'João Santos',
      );

      expect(summary, contains('João Santos'));
      expect(summary, contains('SÍNTESE DE SESSÃO CLÍNICA'));
      expect(summary, contains('higiene do sono'));
    });
  });
}
