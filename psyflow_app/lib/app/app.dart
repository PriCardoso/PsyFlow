import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_gate.dart';

class PsyFlowApp extends StatelessWidget {
  const PsyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsyFlow',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const AuthGate(),
    );
  }
}