import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  /// Psicólogo cria uma tarefa para um paciente
  Future<void> createTask({
    required String patientId,
    required String title,
    String? description,
    String? category,
    String? protocol,
    int difficultyLevel = 1,
    DateTime? dueDate,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await supabase.from('tasks').insert({
        'psychologist_id': user.id,
        'patient_id': patientId,
        'title': title,
        'description': description,
        'category': category,
        'protocol': protocol,
        'difficulty_level': difficultyLevel,
        'due_date': dueDate?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao criar tarefa: $e');
    }
  }

  

  /// Psicólogo vê todas as tarefas que criou (com nome do paciente)
  Future<List<TaskItem>> getTasksCreatedByMe() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('tasks')
          .select('*, patient:patient_id(full_name)')
          .eq('psychologist_id', user.id)
          .order('due_date', ascending: true);

      return (data as List)
          .map((item) => TaskItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  /// Psicólogo vê tarefas de um paciente específico
  Future<List<TaskItem>> getTasksForPatient(String patientId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('tasks')
          .select()
          .eq('psychologist_id', user.id)
          .eq('patient_id', patientId)
          .order('due_date', ascending: true);

      return (data as List)
          .map((item) => TaskItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  /// Paciente vê suas próprias tarefas
  Future<List<TaskItem>> getMyTasks() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final data = await supabase
          .from('tasks')
          .select()
          .eq('patient_id', user.id)
          .order('due_date', ascending: true);

      return (data as List)
          .map((item) => TaskItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  Future<void> completeTask({
    required String taskId,
    required String response,
    required int moodBefore,
    required int moodAfter,
  }) async {
    try {
      await supabase
          .from('tasks')
          .update({
            'status': 'completed',
            'completed_at': DateTime.now().toIso8601String(),
            'patient_response': response,
            'mood_before': moodBefore,
            'mood_after': moodAfter,
          })
          .eq('id', taskId);
    } catch (e) {
      throw Exception(
        'Erro ao concluir tarefa: $e',
      );
    }
  }

  /// Paciente marca tarefa como concluída/pendente
  Future<void> toggleTaskStatus(String taskId, bool completed) async {
    try {
      await supabase.from('tasks').update({
        'status': completed ? 'completed' : 'pending',
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      }).eq('id', taskId);
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: $e');
    }
  }

  /// Psicólogo exclui uma tarefa
  Future<void> deleteTask(String taskId) async {
    try {
      await supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      throw Exception('Erro ao excluir tarefa: $e');
    }
  }
}
