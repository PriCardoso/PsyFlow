import 'package:firebase_auth/firebase_auth.dart';
import '../../core/utils/retry.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await retry(() async {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }, retries: 3, initialDelay: Duration(milliseconds: 500));
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await retry(() async {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }, retries: 3, initialDelay: Duration(milliseconds: 500));
  }

  Future<void> logout() async {
    await retry(() async {
      await _auth.signOut();
    }, retries: 2, initialDelay: Duration(milliseconds: 300));
  }

  Future<void> resetPassword(
    String email,
  ) async {
    await retry(() async {
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );
    }, retries: 3, initialDelay: Duration(milliseconds: 500));
  }

  Future<void> updatePassword(
    String password,
  ) async {
    await retry(() async {
      await currentUser?.updatePassword(password);
    }, retries: 3, initialDelay: Duration(milliseconds: 500));
  }
}