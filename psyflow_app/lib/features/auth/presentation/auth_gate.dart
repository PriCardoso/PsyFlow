import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_service.dart';
import 'pages/login_page.dart';
import 'pages/complete_profile_page.dart';
import '../../dashboard/pages/psychologist_dashboard_page.dart';
import 'pages/reset_password_page.dart';
import '../../dashboard/pages/patient_dashboard_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;
  Future<Map<String, dynamic>?>? _profileFuture;
  String? _lastUserId;
  bool _isRecoveryMode = false; // 👈 novo

  @override
  void initState() {
    super.initState();
    _checkRecoveryFromUrl(); // 👈 novo
    _updateProfileFuture();
  }

  // 👇 detecta o ?code= na URL ao abrir o app (Flutter Web)
  void _checkRecoveryFromUrl() {
    if (!kIsWeb) return;

    final uri = Uri.base;
    final code = uri.queryParameters['code'];

    if (code != null && code.isNotEmpty) {
      setState(() => _isRecoveryMode = true);
    }
  }

  void _updateProfileFuture() {
    final user = supabase.auth.currentUser;
    if (user != null && user.id != _lastUserId) {
      _lastUserId = user.id;
      _profileFuture = UserService().getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 se detectou ?code= na URL, vai direto para reset
    if (_isRecoveryMode) {
      return const ResetPasswordPage();
    }

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        final recovery =
            snapshot.data?.event == AuthChangeEvent.passwordRecovery;

        if (recovery) {
          return const ResetPasswordPage();
        }

        if (session == null) {
          _lastUserId = null;
          _profileFuture = null;
          return const LoginPage();
        }

        _updateProfileFuture();

        return FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      const Text('Erro ao carregar perfil.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _lastUserId = null;
                          _updateProfileFuture();
                        }),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = profileSnapshot.data;

            if (profile == null || profile['profile_complete'] != true) {
              final role = profile?['role'] as String? ?? 'patient';
              return CompleteProfilePage(role: role);
            }

            final role = profile['role'] as String?;
            final fullName = profile['full_name'] as String?;

            if (role == 'psychologist') {
              return PsychologistDashboardPage(initialName: fullName);
            }

            if (role == 'patient') {
              return PatientDashboardPage(initialName: fullName);
            }

            return const LoginPage();
          },
        );
      },
    );
  }
}