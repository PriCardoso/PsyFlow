import 'package:flutter/material.dart';
import 'package:psyflow_app/core/theme/app_colors.dart';
import 'package:psyflow_app/features/patient/patient_tasks_page.dart';
import 'package:psyflow_app/features/mood/mood_page.dart';
import 'package:psyflow_app/features/appointments/book_appointment_page.dart';
import 'package:psyflow_app/features/dashboard/pages/patient_dashboard_page.dart';
import 'package:psyflow_app/features/patients/presentation/pages/link_patient_page.dart';
import 'package:psyflow_app/features/tasks/psychologist_tasks_page.dart';
import 'package:psyflow_app/features/psychologist/manage_availability_page.dart';
import 'package:psyflow_app/features/dashboard/pages/psychologist_dashboard_page.dart';
import 'package:psyflow_app/models/user_model.dart';

enum NavigationProfile { patient, professional }

class AppNavigationBar extends StatefulWidget {
  final NavigationProfile profile;
  final int initialIndex;
  final ValueChanged<int>? onTap;

  const AppNavigationBar({
    super.key,
    required this.profile,
    this.initialIndex = 0,
    this.onTap,
  });

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<NavigationDestination> get _destinations {
    switch (widget.profile) {
      case NavigationProfile.patient:
        return [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today_rounded),
            label: 'Consultas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt_rounded),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            selectedIcon: const Icon(Icons.spa_rounded),
            label: 'Acompanhamento',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ];
      case NavigationProfile.professional:
        return [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today_rounded),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: 'Pacientes',
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt_rounded),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ];
    }
  }

  Color get _selectedColor {
    return widget.profile == NavigationProfile.patient ? AppColors.patient : AppColors.psychologist;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
        widget.onTap?.call(index);
      },
      indicatorColor: _selectedColor.withAlpha(30),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      height: 70,
      destinations: _destinations,
    );
  }
}

class AppScaffold extends StatefulWidget {
  final NavigationProfile profile;
  final int initialIndex;
  final String? userName;
  final String? userEmail;
  final String? userRole;
  final Color accentColor;
  final List<Widget> Function(int index) pageBuilder;

  const AppScaffold({
    super.key,
    required this.profile,
    required this.pageBuilder,
    this.initialIndex = 0,
    this.userName,
    this.userEmail,
    this.userRole,
    required this.accentColor,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.pageBuilder(_currentIndex);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppNavigationBar(
        profile: widget.profile,
        initialIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class PatientNavigationScaffold extends StatelessWidget {
  final String? userName;
  final String? userEmail;

  const PatientNavigationScaffold({
    super.key,
    this.userName,
    this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      profile: NavigationProfile.patient,
      userName: userName,
      userEmail: userEmail,
      userRole: 'Paciente',
      accentColor: AppColors.patient,
      pageBuilder: (index) => [
        PatientDashboardPage(initialName: userName),
        BookAppointmentPage(),
        PatientTasksPage(),
        MoodPage(),
        _PatientProfilePage(),
      ],
    );
  }
}

class ProfessionalNavigationScaffold extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final ProfessionalSpecialty? specialty;

  const ProfessionalNavigationScaffold({
    super.key,
    this.userName,
    this.userEmail,
    this.specialty,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = specialty != null
        ? AppColors.getSpecialtyColor(specialty!.name)
        : AppColors.psychologist;

    return AppScaffold(
      profile: NavigationProfile.professional,
      userName: userName,
      userEmail: userEmail,
      userRole: specialty?.label ?? 'Profissional',
      accentColor: accentColor,
      pageBuilder: (index) => [
        PsychologistDashboardPage(initialName: userName),
        ManageAvailabilityPage(),
        LinkPatientPage(),
        PsychologistTasksPage(),
        _ProfessionalProfilePage(),
      ],
    );
  }
}

class _PatientProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(child: Text('Página de Perfil do Paciente')),
    );
  }
}

class _ProfessionalProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(child: Text('Página de Perfil do Profissional')),
    );
  }
}