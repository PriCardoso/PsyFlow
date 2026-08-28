import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../patients/presentation/pages/link_patient_page.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Redireciona para a nova tela de vínculo com pacientes (LinkPatientPage)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LinkPatientPage()),
      );
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppColors.psychologist)),
    );
  }
}