import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_service.dart';
import 'pages/login_page.dart';
import 'pages/complete_profile_page.dart';
import '../../dashboard/pages/psychologist_dashboard_page.dart';
import '../../dashboard/pages/patient_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (snapshot.hasData) {
          return _ProfileFutureBuilder(user: snapshot.data!);
        }
        return const LoginPage();
      },
    );
  }
}

class _ProfileFutureBuilder extends StatefulWidget {
  final User user;
  const _ProfileFutureBuilder({required this.user});

  @override
  State<_ProfileFutureBuilder> createState() => _ProfileFutureBuilderState();
}

class _ProfileFutureBuilderState extends State<_ProfileFutureBuilder> {
  Future<Map<String, dynamic>?>? _profileFuture;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _updateProfileFuture();
  }

  @override
  void didUpdateWidget(covariant _ProfileFutureBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid) {
      _updateProfileFuture();
    }
  }

  void _updateProfileFuture() {
    if (widget.user.uid != _lastUserId) {
      _lastUserId = widget.user.uid;
      _profileFuture = UserService().getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        final fullName = profile['full_name'] as String? ?? profile['fullName'] as String?;

        if (role == 'psychologist' || role == 'professional') {
          return PsychologistDashboardPage(initialName: fullName);
        }

        if (role == 'patient') {
          return PatientDashboardPage(initialName: fullName);
        }

        return const LoginPage();
      },
    );
  }
}