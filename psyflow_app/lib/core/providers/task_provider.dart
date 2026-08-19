import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/task_service.dart';
import '../../core/errors/app_exception.dart';
import '../../models/task_item.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = sl<TaskService>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  List<TaskItem> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskItem> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyTasks() async {
    final user = _auth.currentUser;
    if (user == null) {
      _tasks = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getMyTasks();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('TaskProvider.loadMyTasks error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksForPatient(String patientId) async {
    final user = _auth.currentUser;
    if (user == null) {
      _tasks = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasksForPatient(patientId);
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('TaskProvider.loadTasksForPatient error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTasksCreatedByMe() async {
    final user = _auth.currentUser;
    if (user == null) {
      _tasks = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasksCreatedByMe();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('TaskProvider.loadTasksCreatedByMe error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<TaskItem>> getMyTasksStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _taskService.tasksStreamForPatient(user.uid);
  }

  Stream<List<TaskItem>> getTasksStreamForPsychologist(String psychologistId) {
    return _taskService.tasksStreamForPsychologist(psychologistId);
  }

  Future<void> createTask({
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
      await loadTasksCreatedByMe();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> completeTask({
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
      await loadMyTasks();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> toggleTaskStatus(String taskId, bool completed) async {
    try {
      await _taskService.toggleTaskStatus(taskId, completed);
      await loadMyTasks();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      await loadTasksCreatedByMe();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> saveTherapistNotes({
    required String taskId,
    required String notes,
  }) async {
    try {
      await _taskService.saveTherapistNotes(taskId: taskId, notes: notes);
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}