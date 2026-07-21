import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../models/appointment_item.dart';
import '../../models/availability_slot.dart';
import '../../core/services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService(FirebaseFirestore.instance);

  List<AppointmentItem> _appointments = [];
  List<AvailabilitySlot> _slots = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _appointmentsSubscription;
  StreamSubscription? _slotsSubscription;

  List<AppointmentItem> get appointments => _appointments;
  List<AvailabilitySlot> get slots => _slots;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppointmentItem> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.startTime.isAfter(now) && a.status == 'scheduled')
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<AppointmentItem> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) => a.startTime.isBefore(now) || a.status != 'scheduled')
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<AvailabilitySlot> get availableSlots {
    return _slots.where((s) => s.isActive && !s.isBooked).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<void> loadAppointmentsAsPatient(String userId) async {
    _cancelSubscriptions();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointmentsSubscription = _appointmentService
          .appointmentsStreamForPatient(userId)
          .listen(
        (appointments) {
          _appointments = appointments;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar consultas: $e';
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

  Future<void> loadAppointmentsAsPsychologist(String userId) async {
    _cancelSubscriptions();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointmentsSubscription = _appointmentService
          .appointmentsStreamForPsychologist(userId)
          .listen(
        (appointments) {
          _appointments = appointments;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar consultas: $e';
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

  Future<void> loadSlotsForPsychologist(String psychologistId) async {
    _cancelSubscriptions();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _slotsSubscription = _appointmentService
          .slotsStreamForPsychologist(psychologistId)
          .listen(
        (slots) {
          _slots = slots;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar horários: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao iniciar listener de horários: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSlot({
    required String psychologistId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required String modality,
  }) async {
    try {
      await _appointmentService.addAvailabilitySlot(
        psychologistId: psychologistId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        modality: modality,
      );
      return true;
    } catch (e) {
      _error = 'Erro ao adicionar horário: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeSlot(String slotId) async {
    try {
      await _appointmentService.deleteSlot(slotId);
      return true;
    } catch (e) {
      _error = 'Erro ao remover horário: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> bookAppointment({
    required String psychologistId,
    required String patientId,
    required AvailabilitySlot slot,
    required String modality,
  }) async {
    try {
      await _appointmentService.bookAppointment(
        psychologistId: psychologistId,
        patientId: patientId,
        slot: slot,
        modality: modality,
      );
      return true;
    } catch (e) {
      _error = 'Erro ao agendar consulta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _appointmentService.cancelAppointment(appointmentId);
      return true;
    } catch (e) {
      _error = 'Erro ao cancelar consulta: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<AvailabilitySlot>> getAvailableSlotsForPsychologist(String psychologistId) async {
    try {
      return await _appointmentService.getAvailableSlotsForPsychologist(psychologistId);
    } catch (e) {
      _error = 'Erro ao buscar horários: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<AppointmentItem>> getMyAppointmentsAsPatient(String userId) async {
    try {
      return await _appointmentService.getMyAppointmentsAsPatient(userId);
    } catch (e) {
      _error = 'Erro ao buscar consultas: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<AppointmentItem>> getMyAppointmentsAsPsychologist(String userId) async {
    try {
      return await _appointmentService.getMyAppointmentsAsPsychologist(userId);
    } catch (e) {
      _error = 'Erro ao buscar consultas: $e';
      notifyListeners();
      return [];
    }
  }

  void _cancelSubscriptions() {
    _appointmentsSubscription?.cancel();
    _slotsSubscription?.cancel();
    _appointmentsSubscription = null;
    _slotsSubscription = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}