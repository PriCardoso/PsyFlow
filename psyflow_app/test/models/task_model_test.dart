import 'package:flutter_test/flutter_test.dart';
import 'package:psyflow_app/models/task_item.dart';

void main() {
  group('TaskItem Model', () {
    test('TaskItem.fromMap parses all fields correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 'task-123',
        'task_id': 'template-456',
        'patient_id': 'patient-789',
        'psychologist_id': 'psych-101',
        'title': 'Registro de Pensamentos Disfuncionais',
        'description': 'Anotar pensamentos automáticos',
        'category': 'cbt',
        'protocol': 'TCC Padrão',
        'difficulty_level': 2,
        'status': 'pending',
        'due_date': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'completed_at': null,
        'patient_response': 'Concluído com sucesso',
        'therapist_notes': 'Excelente progresso',
        'mood_before': 2,
        'mood_after': 4,
        'patient_name': 'João Silva',
        'order': 1,
      };

      final item = TaskItem.fromMap(map);

      expect(item.id, 'task-123');
      expect(item.taskId, 'template-456');
      expect(item.patientId, 'patient-789');
      expect(item.psychologistId, 'psych-101');
      expect(item.title, 'Registro de Pensamentos Disfuncionais');
      expect(item.description, 'Anotar pensamentos automáticos');
      expect(item.category, 'cbt');
      expect(item.protocol, 'TCC Padrão');
      expect(item.difficultyLevel, 2);
      expect(item.status, 'pending');
      expect(item.isCompleted, isFalse);
      expect(item.patientResponse, 'Concluído com sucesso');
      expect(item.therapistNotes, 'Excelente progresso');
      expect(item.moodBefore, 2);
      expect(item.moodAfter, 4);
      expect(item.patientName, 'João Silva');
      expect(item.order, 1);
    });

    test('TaskItem isCompleted returns true when status is completed', () {
      final task = TaskItem(
        id: '1',
        taskId: '1',
        patientId: 'p1',
        psychologistId: 'psi1',
        title: 'Respiração Diafragmática',
        category: 'geral',
        protocol: '',
        difficultyLevel: 1,
        status: 'completed',
      );

      expect(task.isCompleted, isTrue);
    });

    test('TaskItem isOverdue returns true when due date has passed and status is not completed', () {
      final overdueTask = TaskItem(
        id: '2',
        taskId: '2',
        patientId: 'p1',
        psychologistId: 'psi1',
        title: 'Meditação Mindfulness',
        category: 'mindfulness',
        protocol: '',
        difficultyLevel: 1,
        status: 'pending',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      );

      expect(overdueTask.isOverdue, isTrue);

      final completedOverdueTask = overdueTask.copyWith(status: 'completed');
      expect(completedOverdueTask.isOverdue, isFalse);
    });

    test('TaskItem copyWith updates fields correctly', () {
      final original = TaskItem(
        id: '1',
        taskId: 't1',
        patientId: 'p1',
        psychologistId: 'psi1',
        title: 'Diário de Gratidão',
        category: 'geral',
        protocol: '',
        difficultyLevel: 1,
        status: 'pending',
      );

      final updated = original.copyWith(
        status: 'completed',
        patientResponse: 'Me senti muito melhor!',
        moodAfter: 5,
      );

      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.status, 'completed');
      expect(updated.patientResponse, 'Me senti muito melhor!');
      expect(updated.moodAfter, 5);
    });
  });
}