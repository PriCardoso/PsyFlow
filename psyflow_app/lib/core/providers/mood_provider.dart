import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/mood_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/errors/app_exception.dart';
import '../../models/mood_model.dart';

class MoodProvider extends ChangeNotifier {
  final MoodService _moodService = sl<MoodService>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String? _error;
  bool _hasEntryToday = false;

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasEntryToday => _hasEntryToday;

  Future<void> loadMyEntries({int limit = 30}) async {
    final user = _auth.currentUser;
    if (user == null) {
      _entries = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _moodService.getMyEntries(limit: limit);
      _hasEntryToday = await _moodService.hasEntryToday();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('MoodProvider.loadMyEntries error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPatientEntries(String patientId, {int limit = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _moodService.getPatientEntries(patientId, limit: limit);
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('MoodProvider.loadPatientEntries error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<MoodEntry>> getMyMoodStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _moodService.moodStreamForPatient(user.uid);
  }

  Future<void> addEntry({
    required int mood,
    required int anxiety,
    required int energy,
    String? notes,
  }) async {
    try {
      await _moodService.addEntry(
        mood: mood,
        anxiety: anxiety,
        energy: energy,
        notes: notes,
      );
      // Log analytics
      sl<AnalyticsService>().logMoodLogged(moodScore: mood).ignore();
      await loadMyEntries();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> checkHasEntryToday() async {
    try {
      _hasEntryToday = await _moodService.hasEntryToday();
      notifyListeners();
    } catch (e) {
      debugPrint('MoodProvider.checkHasEntryToday error: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}