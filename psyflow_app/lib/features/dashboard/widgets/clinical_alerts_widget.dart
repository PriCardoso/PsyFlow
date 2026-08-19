import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/mood_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/mood_model.dart';
import '../../../models/task_item.dart';

class ClinicalAlert {
  final String title;
  final String description;
  final AlertLevel level;
  final IconData icon;

  const ClinicalAlert({
    required this.title,
    required this.description,
    required this.level,
    required this.icon,
  });
}

enum AlertLevel { high, medium, low }

class ClinicalAlertsWidget extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ClinicalAlertsWidget({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<ClinicalAlertsWidget> createState() => _ClinicalAlertsWidgetState();
}

class _ClinicalAlertsWidgetState extends State<ClinicalAlertsWidget> {
  final _moodService = sl<MoodService>();
  final _taskService = sl<TaskService>();

  List<ClinicalAlert> _alerts = [];
  bool _loading = true;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final moods = await _moodService.getPatientEntries(widget.patientId, limit: 7);
      final tasks = await _taskService.getTasksForPatient(widget.patientId);
      final alerts = _analyze(moods, tasks);
      if (mounted) setState(() => _alerts = alerts);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<ClinicalAlert> _analyze(List<MoodEntry> moods, List<TaskItem> tasks) {
    final alerts = <ClinicalAlert>[];

    // Humor consistentemente baixo (< 4 nos últimos 3 registros)
    if (moods.length >= 3) {
      final recent = moods.take(3).toList();
      final avgMood = recent.map((m) => m.mood).reduce((a, b) => a + b) / recent.length;
      if (avgMood < 2.5) {
        alerts.add(const ClinicalAlert(
          title: 'Humor persistentemente baixo',
          description: 'Média abaixo de 2.5/5 nos últimos 3 registros.',
          level: AlertLevel.high,
          icon: Icons.sentiment_very_dissatisfied_rounded,
        ));
      }
    }

    // Ansiedade elevada
    if (moods.isNotEmpty) {
      final recent = moods.take(3).toList();
      final avgAnx = recent.map((m) => m.anxiety).reduce((a, b) => a + b) / recent.length;
      if (avgAnx > 4) {
        alerts.add(const ClinicalAlert(
          title: 'Ansiedade elevada',
          description: 'Nível médio de ansiedade acima de 4/5 nos últimos registros.',
          level: AlertLevel.high,
          icon: Icons.warning_amber_rounded,
        ));
      } else if (avgAnx > 3) {
        alerts.add(const ClinicalAlert(
          title: 'Ansiedade moderada',
          description: 'Nível médio de ansiedade entre 3 e 4 nos últimos registros.',
          level: AlertLevel.medium,
          icon: Icons.info_outline_rounded,
        ));
      }
    }

    // Energia muito baixa
    if (moods.isNotEmpty) {
      final recent = moods.take(3).toList();
      final avgEnergy = recent.map((m) => m.energy).reduce((a, b) => a + b) / recent.length;
      if (avgEnergy < 2) {
        alerts.add(const ClinicalAlert(
          title: 'Energia muito baixa',
          description: 'Nível de energia abaixo de 2/5 — pode indicar fadiga ou apatia.',
          level: AlertLevel.medium,
          icon: Icons.battery_1_bar_rounded,
        ));
      }
    }

    // Tarefas atrasadas
    final overdue = tasks.where((t) => t.isOverdue).length;
    if (overdue >= 3) {
      alerts.add(ClinicalAlert(
        title: '$overdue tarefas em atraso',
        description: 'Paciente tem múltiplas tarefas não concluídas no prazo.',
        level: AlertLevel.medium,
        icon: Icons.assignment_late_rounded,
      ));
    } else if (overdue >= 1) {
      alerts.add(ClinicalAlert(
        title: '$overdue tarefa(s) em atraso',
        description: 'Verifique se o paciente encontrou dificuldades.',
        level: AlertLevel.low,
        icon: Icons.assignment_late_outlined,
      ));
    }

    // Sem registros de humor recentes
    if (moods.isEmpty) {
      alerts.add(const ClinicalAlert(
        title: 'Sem registros de humor',
        description: 'Paciente ainda não registrou nenhum estado emocional.',
        level: AlertLevel.low,
        icon: Icons.mood_bad_outlined,
      ));
    } else {
      final last = moods.first.createdAt;
      final daysSince = DateTime.now().difference(last).inDays;
      if (daysSince >= 5) {
        alerts.add(ClinicalAlert(
          title: 'Inativo há $daysSince dias',
          description: 'Último registro de humor foi há $daysSince dias.',
          level: daysSince >= 10 ? AlertLevel.high : AlertLevel.medium,
          icon: Icons.calendar_today_rounded,
        ));
      }
    }

    // Ordenar por gravidade
    alerts.sort((a, b) => a.level.index.compareTo(b.level.index));
    return alerts;
  }

  Color _levelColor(AlertLevel level) {
    return switch (level) {
      AlertLevel.high => AppColors.error,
      AlertLevel.medium => AppColors.accentLight,
      AlertLevel.low => AppColors.psychologist,
    };
  }

  Color _levelBg(AlertLevel level) {
    return switch (level) {
      AlertLevel.high => AppColors.error.withValues(alpha: 0.08),
      AlertLevel.medium => AppColors.accentLight.withValues(alpha: 0.1),
      AlertLevel.low => AppColors.psychologist.withValues(alpha: 0.07),
    };
  }

  String _levelLabel(AlertLevel level) {
    return switch (level) {
      AlertLevel.high => 'Alta',
      AlertLevel.medium => 'Média',
      AlertLevel.low => 'Baixa',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7ECF1)),
        ),
        child: const Center(
          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.psychologist)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECF1)),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _alerts.isEmpty
                          ? AppColors.success.withValues(alpha: 0.1)
                          : _alerts.first.level == AlertLevel.high
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.cardOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      _alerts.isEmpty ? Icons.check_circle_outline_rounded : Icons.notifications_active_rounded,
                      size: 17,
                      color: _alerts.isEmpty
                          ? AppColors.success
                          : _alerts.first.level == AlertLevel.high
                              ? AppColors.error
                              : AppColors.cardOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alertas clínicos',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          _alerts.isEmpty
                              ? 'Nenhum alerta identificado'
                              : '${_alerts.length} alerta(s) • ${widget.patientName.split(' ').first}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFE7ECF1)),
            if (_alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Tudo dentro do esperado para ${widget.patientName.split(' ').first}.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: _alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final alert = _alerts[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _levelBg(alert.level),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(alert.icon, size: 18, color: _levelColor(alert.level)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _levelColor(alert.level),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _levelColor(alert.level).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _levelLabel(alert.level),
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _levelColor(alert.level)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                alert.description,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}
