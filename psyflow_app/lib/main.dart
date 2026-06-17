import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/presentation/pages/reset_password_page.dart'; // 👈

// 👇 navegator key para navegar fora do contexto
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://krwyrfjhisodzuhqxvrq.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtyd3lyZmpoaXNvZHp1aHF4dnJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNDY3MTMsImV4cCI6MjA5NjcyMjcxM30.Abqd3GFxX1nVdilY6rfuBXrJcbga8CkqdYVYkZLEGck',
  );

  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;

    // 👇 quando o Supabase detecta o link de recuperação, navega para a tela
    if (event == AuthChangeEvent.passwordRecovery) {
      debugPrint('Modo recuperação de senha — redirecionando...');
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ResetPasswordPage(),
        ),
        (_) => false,
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorKey: navigatorKey, // 👈 registra a key aqui
      home: const AuthGate(),
    );
  }
}