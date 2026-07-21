import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../core/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isPsychologist => _currentUser?.role == UserRole.psychologist;
  bool get isPatient => _currentUser?.role == UserRole.patient;

  UserProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> loadUserProfile(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = await _userService.getProfile();
      if (profile != null) {
        _currentUser = UserModel.fromMap(profile, uid);
      }
    } catch (e) {
      _error = 'Erro ao carregar perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeProfile({
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
      await loadUserProfile(_auth.currentUser!.uid);
      return true;
    } catch (e) {
      _error = 'Erro ao completar perfil: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? bio,
    String? crp,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.saveProfile(
        role: _currentUser!.role.name,
        fullName: fullName ?? _currentUser!.fullName,
        phone: phone ?? _currentUser!.phone,
        crp: crp ?? _currentUser!.crp,
        bio: bio ?? _currentUser!.bio,
      );
      await loadUserProfile(_auth.currentUser!.uid);
    } catch (e) {
      _error = 'Erro ao atualizar perfil: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}