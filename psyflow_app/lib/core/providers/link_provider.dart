import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/therapist_patient_service.dart';
import '../../core/errors/app_exception.dart';
import '../../models/patient_link_model.dart';

/// Provider de vínculo psicólogo ↔ paciente.
/// Utiliza exclusivamente o [TherapistPatientService] (canônico).
class LinkProvider extends ChangeNotifier {
  final TherapistPatientService _linkService = sl<TherapistPatientService>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  /// Pacientes do psicólogo (com métricas)
  List<TherapistPatientLink> _myPatients = [];

  /// Profissionais do paciente (N:N)
  List<TherapistPatientLink> _myTherapists = [];

  bool _isLoading = false;
  String? _error;

  List<TherapistPatientLink> get myPatients => _myPatients;
  List<TherapistPatientLink> get myTherapists => _myTherapists;

  /// Retrocompatibilidade: primeiro psicólogo vinculado ao paciente
  Map<String, dynamic>? get myPsychologist =>
      _myTherapists.isNotEmpty ? _buildTherapistMap(_myTherapists.first) : null;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Map<String, dynamic> _buildTherapistMap(TherapistPatientLink link) {
    return {
      'linkId': link.id,
      'status': link.status.name,
      'acceptedAt': link.acceptedAt,
      'psychologist_id': link.psychologistId,
      'psychologistId': link.psychologistId,
      'psychologist': link.therapistProfile != null
          ? {
              'id': link.therapistProfile!.id,
              'full_name': link.therapistProfile!.fullName,
              'email': link.therapistProfile!.email,
              'specialty': link.therapistProfile!.specialty,
              'crp': link.therapistProfile!.professionalRegistration,
              'professional_registration':
                  link.therapistProfile!.professionalRegistration,
              'photo_url': link.therapistProfile!.photoUrl,
              'bio': link.therapistProfile!.bio,
            }
          : null,
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Psicólogo: carregar pacientes
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> loadMyPatients() async {
    final user = _auth.currentUser;
    if (user == null) {
      _myPatients = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myPatients = await _linkService.getMyPatients();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('LinkProvider.loadMyPatients error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Paciente: carregar psicólogos
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> loadMyTherapists() async {
    final user = _auth.currentUser;
    if (user == null) {
      _myTherapists = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myTherapists = await _linkService.getMyTherapists();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('LinkProvider.loadMyTherapists error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retrocompatibilidade: alias de loadMyTherapists
  Future<void> loadMyPsychologist() => loadMyTherapists();

  // ──────────────────────────────────────────────────────────────────────────
  // Gerar código (psicólogo)
  // ──────────────────────────────────────────────────────────────────────────

  Future<String> generateInvite() async {
    try {
      final code = await _linkService.generateInviteCode();
      return code;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      notifyListeners();
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Aceitar código (paciente)
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> useInvite(String code) async {
    try {
      await _linkService.acceptInviteCode(code);
      await loadMyTherapists();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      notifyListeners();
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Gerenciar vínculos
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> deactivateLink(String linkId) async {
    try {
      await _linkService.deactivateLink(linkId);
      await loadMyPatients();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reactivateLink(String linkId) async {
    try {
      await _linkService.reactivateLink(linkId);
      await loadMyPatients();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
