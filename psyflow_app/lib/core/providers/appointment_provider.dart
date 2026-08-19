import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/appointment_service.dart';
import '../../core/services/user_service.dart';
import '../../core/errors/app_exception.dart';
import '../../models/appointment_item.dart';
import '../../models/availability_slot.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = sl<AppointmentService>();
  final UserService _userService = sl<UserService>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  List<AppointmentItem> _appointments = [];
  List<AvailabilitySlot> _slots = [];
  bool _isLoading = false;
  String? _error;

  List<AppointmentItem> get appointments => _appointments;
  List<AvailabilitySlot> get slots => _slots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyAppointments() async {
    final user = _auth.currentUser;
    if (user == null) {
      _appointments = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await _userService.getProfile();
      final role = profile?['role'] as String?;
      if (role == 'psychologist' || role == 'professional') {
        _appointments = await _appointmentService.getMyAppointmentsAsPsychologist(user.uid);
      } else {
        _appointments = await _appointmentService.getMyAppointmentsAsPatient(user.uid);
      }
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('AppointmentProvider.loadMyAppointments error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMySlots() async {
    final user = _auth.currentUser;
    if (user == null) {
      _slots = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _slots = await _appointmentService.getMySlots(user.uid);
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('AppointmentProvider.loadMySlots error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<AppointmentItem>> getMyAppointmentsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    // For streams, we can't easily get role async, so we'll use a StreamBuilder pattern
    // or return both streams merged. For now, default to patient stream and let UI handle.
    return _appointmentService.appointmentsStreamForPatient(user.uid);
  }

  Stream<List<AvailabilitySlot>> getMySlotsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _appointmentService.slotsStreamForPsychologist(user.uid);
  }

  Future<void> addAvailabilitySlot({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required String modality,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await _appointmentService.addAvailabilitySlot(
        psychologistId: user.uid,
        date: date,
        startTime: startTime,
        endTime: endTime,
        modality: modality,
      );
      await loadMySlots();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> deleteSlot(String slotId) async {
    try {
      await _appointmentService.deleteSlot(slotId);
      await loadMySlots();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> bookAppointment({
    required String psychologistId,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw AppException('Usuário não autenticado.');

    try {
      await _appointmentService.bookAppointment(
        psychologistId: psychologistId,
        patientId: user.uid,
        slot: slot,
        modality: modality,
      );
      await loadMyAppointments();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(appointmentId);
      await loadMyAppointments();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<List<AvailabilitySlot>> getAvailableSlotsForPsychologist(String psychologistId) async {
    try {
      return await _appointmentService.getAvailableSlotsForPsychologist(psychologistId);
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listAvailablePsychologists() async {
    try {
      final psychologists = await _appointmentService.listAvailablePsychologists();
      return psychologists.map((p) => p.toMap()).toList();
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