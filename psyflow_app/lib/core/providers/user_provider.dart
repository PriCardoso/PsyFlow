import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/user_service.dart';
import '../../core/errors/app_exception.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = sl<UserService>();
  final FirebaseAuth _auth = sl<FirebaseAuth>();

  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;
  String? get userRole => _profile?['role'] as String?;
  String? get fullName => _profile?['full_name'] as String?;
  bool get isProfileComplete => _profile?['profile_complete'] == true;

  Future<void> loadProfile() async {
    if (_auth.currentUser == null) {
      _profile = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _userService.getProfile();
      _error = null;
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      debugPrint('UserProvider.loadProfile error: $appException');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile({
    required String role,
    required String fullName,
    String? phone,
    String? crp,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.saveProfile(
        role: role,
        fullName: fullName,
        phone: phone,
        crp: crp,
        bio: bio,
      );
      await loadProfile();
    } catch (e) {
      final appException = mapToAppException(e);
      _error = appException.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void logout() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}