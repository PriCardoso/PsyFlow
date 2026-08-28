import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/patient_model.dart';
import '../../models/patient_link_model.dart';
import '../../repositories/patient_repository.dart';

class PatientProvider extends ChangeNotifier {
  final PatientRepository _repository;

  PatientProvider({PatientRepository? repository})
      : _repository = repository ?? FirestorePatientRepository(firestore: FirebaseFirestore.instance);

  List<PatientLink> _myPatients = [];
  PatientProfile? _myProfessional;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _patientsSubscription;
  StreamSubscription? _professionalSubscription;

  List<PatientLink> get myPatients => _myPatients;
  PatientProfile? get myProfessional => _myProfessional;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPatients => _myPatients.isNotEmpty;
  int get activePatientsCount => _myPatients.where((p) => p.active).length;

  Future<void> loadMyPatients(String professionalId) async {
    _cancelSubscriptions();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _patientsSubscription = _repository.streamPatientsForProfessional(professionalId).listen(
        (patients) {
          _myPatients = patients;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = 'Erro ao carregar pacientes: $e';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao iniciar listener de pacientes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyProfessional(String patientId) async {
    _cancelSubscriptions();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final link = await _repository.getProfessionalForPatient(patientId);
      if (link != null) {
        _myProfessional = link['psychologist'] as PatientProfile?;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar profissional: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPatientsOnce(String professionalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final patients = await _repository.getPatientsForProfessional(professionalId);
      _myPatients = patients;
    } catch (e) {
      _error = 'Erro ao carregar pacientes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfessionalOnce(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final link = await _repository.getProfessionalForPatient(patientId);
      if (link != null) {
        _myProfessional = link['psychologist'] as PatientProfile?;
      }
    } catch (e) {
      _error = 'Erro ao carregar profissional: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> invitePatient(String professionalId, String patientEmail) async {
    try {
      return true;
    } catch (e) {
      _error = 'Erro ao convidar paciente: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivatePatient(String linkId) async {
    try {
      await _repository.deactivateLink(linkId);
      final index = _myPatients.indexWhere((p) => p.linkId == linkId);
      if (index != -1) {
        _myPatients[index] = PatientLink(
          linkId: _myPatients[index].linkId,
          active: false,
          createdAt: _myPatients[index].createdAt,
          patient: _myPatients[index].patient,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Erro ao desvincular paciente: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reactivatePatient(String linkId) async {
    try {
      await _repository.reactivateLink(linkId);
      final index = _myPatients.indexWhere((p) => p.linkId == linkId);
      if (index != -1) {
        _myPatients[index] = PatientLink(
          linkId: _myPatients[index].linkId,
          active: true,
          createdAt: _myPatients[index].createdAt,
          patient: _myPatients[index].patient,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Erro ao reativar paciente: $e';
      notifyListeners();
      return false;
    }
  }

  PatientLink? getPatientById(String linkId) {
    try {
      return _myPatients.firstWhere((p) => p.linkId == linkId);
    } catch (_) {
      return null;
    }
  }

  void _cancelSubscriptions() {
    _patientsSubscription?.cancel();
    _patientsSubscription = null;
    _professionalSubscription?.cancel();
    _professionalSubscription = null;
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