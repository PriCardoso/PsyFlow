import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/invite_service.dart';
import '../../core/errors/app_exception.dart';
import '../../models/patient_link_model.dart';

class InviteProvider extends ChangeNotifier {
  final InviteService _inviteService = sl<InviteService>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  List<Map<String, dynamic>> _myInvites = [];
  List<PatientLink> _myPatients = [];
  Map<String, dynamic>? _myPsychologist;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get myInvites => _myInvites;
  List<PatientLink> get myPatients => _myPatients;
  Map<String, dynamic>? get myPsychologist => _myPsychologist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyInvites() async {
    final user = _auth.currentUser;
    if (user == null) {
      _myInvites = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myInvites = await _inviteService.getMyInvites();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('InviteProvider.loadMyInvites error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      _myPatients = await _inviteService.getMyPatients();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('InviteProvider.loadMyPatients error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyPsychologist() async {
    final user = _auth.currentUser;
    if (user == null) {
      _myPsychologist = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myPsychologist = await _inviteService.getMyPsychologist();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('InviteProvider.loadMyPsychologist error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> generateInvite() async {
    try {
      final code = await _inviteService.generateInvite();
      await loadMyInvites();
      return code;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> useInvite(String code) async {
    try {
      await _inviteService.useInvite(code);
      await loadMyPsychologist();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> deactivateLink(String linkId) async {
    try {
      await _inviteService.deactivateLink(linkId);
      await loadMyPatients();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    }
  }

  Future<void> reactivateLink(String linkId) async {
    try {
      await _inviteService.reactivateLink(linkId);
      await loadMyPatients();
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