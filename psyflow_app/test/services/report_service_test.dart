import 'package:flutter_test/flutter_test.dart';
import 'package:psyflow_app/core/services/report_service.dart';
import 'package:psyflow_app/models/mood_model.dart';
import 'package:psyflow_app/models/task_item.dart';
import 'package:psyflow_app/models/clinical_session_model.dart';
import 'package:psyflow_app/models/clinical_scale_model.dart';

void main() {
  group('ReportService PDF Generation', () {
    test('generatePatientProgressReport returns valid non-empty PDF bytes', () async {
      final reportService = ReportService();
      final now = DateTime.now();

      final moodEntries = [
        MoodEntry(
          id: '1',
          patientId: 'patient-1',
          mood: 4,
          anxiety: 2,
          energy: 4,
          sleepQuality: 8,
          stress: 2,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        MoodEntry(
          id: '2',
          patientId: 'patient-1',
          mood: 5,
          anxiety: 1,
          energy: 5,
          sleepQuality: 7,
          stress: 1,
          createdAt: now,
        ),
      ];

      final tasks = [
        TaskItem(
          id: '1',
          taskId: 't1',
          patientId: 'patient-1',
          psychologistId: 'psi-1',
          title: 'Exercício de Respiração',
          category: 'relaxamento',
          protocol: 'TCC',
          difficultyLevel: 1,
          status: 'completed',
          dueDate: now,
        ),
      ];

      final sessions = [
        ClinicalSessionModel(
          id: 's1',
          patientId: 'patient-1',
          professionalId: 'psi-1',
          sessionDate: now.subtract(const Duration(days: 3)),
          summary: 'Sessão focada em identificação de gatilhos de ansiedade.',
          clinicalNotes: 'Anotações clínicas privadas.',
          goalsAddressed: ['Reduzir ansiedade social'],
          interventionsUsed: ['TCC', 'Exposição Gradual'],
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      ];

      final scaleResponses = [
        ClinicalScaleResponseModel(
          id: 'r1',
          scaleId: 'phq-9',
          scaleCode: 'PHQ-9',
          patientId: 'patient-1',
          professionalId: 'psi-1',
          answers: {0: 1, 1: 1, 2: 0},
          totalScore: 2,
          severityInterpretation: 'Mínima ou Nenhuma',
          completedAt: now,
        ),
      ];

      final pdfBytes = await reportService.generatePatientProgressReport(
        patientName: 'Maria Silva',
        patientId: 'patient-1',
        professionalName: 'Dr. Roberto Santos',
        professionalSpecialty: 'Psicologia Clínica',
        moodEntries: moodEntries,
        tasks: tasks,
        sessions: sessions,
        scaleResponses: scaleResponses,
        periodStart: now.subtract(const Duration(days: 30)),
        periodEnd: now,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF documents start with '%PDF-' header bytes (0x25, 0x50, 0x44, 0x46, 0x2D)
      expect(pdfBytes.sublist(0, 5), [0x25, 0x50, 0x44, 0x46, 0x2D]);
    });
  });
}