import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_item.dart';
import '../../core/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _tasksSubscription;

  List<TaskItem> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TaskItem> get pendingTasks {
    return _tasks
        .where((t) => t.status == 'pending')
        .toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
  }

  List<TaskItem> get completedTasks {
    return _tasks
        .where((t) => t.isCompleted)
        .toList()
      ..sort((a, b) {
        if (a.completedAt == null && b.completedAt == null) return 0;
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
  }

  List<TaskItem> get overdueTasks {
    final now = DateTime.now();
    return _tasks
        .where((t) => !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(now))
        .toList();
  }

  Future<void> loadTasksForPatient(String patientId) async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasksSubscription = _taskService.tasksStreamForPatient(patientId).listen(
        (tasks) {
          _tasks = tasks;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar tarefas: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao iniciar listener: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksForPsychologist(String psychologistId) async {
    _cancelSubscription();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasksSubscription = _taskService.tasksStreamForPsychologist(psychologistId).listen(
        (tasks) {
          _tasks = tasks;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar tarefas: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao iniciar listener: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask({
    required String patientId,
    required String title,
    String? description,
    String? category,
    String? protocol,
    int difficultyLevel = 1,
    DateTime? dueDate,
  }) async {
    try {
      await _taskService.createTask(
        patientId: patientId,
        title: title,
        description: description,
        category: category,
        protocol: protocol,
        difficultyLevel: difficultyLevel,
        dueDate: dueDate,
      );
      return true;
    } catch (e) {
      _error = 'Erro ao criar tarefa: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTask({
    required String taskId,
    required String response,
    required int moodBefore,
    required int moodAfter,
  }) async {
    try {
      await _taskService.completeTask(
        taskId: taskId,
        response: response,
        moodBefore: moodBefore,
        moodAfter: moodAfter,
      );
      return true;
    } catch (e) {
      _error = 'Erro ao concluir tarefa: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskStatus(String taskId, bool completed) async {
    try {
      await _taskService.toggleTaskStatus(taskId, completed);
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar tarefa: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      return true;
    } catch (e) {
      _error = 'Erro ao excluir tarefa: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveTherapistNotes({
    required String taskId,
    required String notes,
  }) async {
    try {
      await _taskService.saveTherapistNotes(taskId: taskId, notes: notes);
      return true;
    } catch (e) {
      _error = 'Erro ao salvar anotação: $e';
      notifyListeners();
      return false;
    }
  }

  void _cancelSubscription() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}