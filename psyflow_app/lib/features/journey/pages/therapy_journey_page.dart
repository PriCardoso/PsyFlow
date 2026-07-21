import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/journey_service.dart';
import '../../../core/services/intervention_service.dart';
import '../../../models/intervention_template.dart';

class TherapyJourneyPage extends StatefulWidget {
  const TherapyJourneyPage({super.key});

  @override
  State<TherapyJourneyPage> createState() => _TherapyJourneyPageState();
}

class _TherapyJourneyPageState extends State<TherapyJourneyPage> {
  final _journeyService = JourneyService();
  final _interventionService = InterventionService();

  Map<String, dynamic>? _journey;
  List<Map<String, dynamic>> _steps = [];
  List<InterventionTemplate> _templates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final journey = await _journeyService.getJourney(userId);
      List<Map<String, dynamic>> steps = [];
      List<InterventionTemplate> templates = [];

      if (journey != null) {
        steps = await _journeyService.getSteps(journey['protocol'] as String);
        templates = await _interventionService.getByCategory(journey['protocol'] as String);
      }

      if (mounted) {
        setState(() {
          _journey = journey;
          _steps = steps;
          _templates = templates;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  bool _isStepCompleted(Map<String, dynamic> step) {
    if (_journey == null) return false;
    final currentPhase = (_journey!['current_phase'] as int?) ?? 0;
    return (step['phase'] as int) < currentPhase;
  }

  bool _isStepCurrent(Map<String, dynamic> step) {
    if (_journey == null) return false;
    final currentPhase = (_journey!['current_phase'] as int?) ?? 0;
    return (step['phase'] as int) == currentPhase;
  }

  double get _progress {
    if (_steps.isEmpty || _journey == null) return 0;
    final current = (_journey!['current_phase'] as int?) ?? 0;
    final total = _steps.length;
    return total > 0 ? (current / total).clamp(0.0, 1.0) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.patient,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.patient, AppColors.accentLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Minha Jornada',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _journey != null
                              ? (_journey!['protocol'] as String? ?? 'Protocolo terapêutico')
                              : 'Acompanhe seu progresso',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                        if (_journey != null) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progress,
                              minHeight: 6,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_progress * 100).round()}% concluído',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.patient)),
            )
          else if (_journey == null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text(
                        'Jornada não iniciada',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Seu psicólogo ainda não iniciou sua jornada terapêutica. Ela aparecerá aqui quando for configurada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.55),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Cards de resumo
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        label: 'Fase atual',
                        value: '${(_journey!['current_phase'] as int?) ?? 0}',
                        icon: Icons.flag_rounded,
                        color: AppColors.patient,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(
                        label: 'Total de fases',
                        value: '${_steps.length}',
                        icon: Icons.route_rounded,
                        color: AppColors.psychologist,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(
                        label: 'Protocolo',
                        value: _journey!['protocol'] as String? ?? '—',
                        icon: Icons.psychology_rounded,
                        color: AppColors.accentLight,
                        small: true,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_steps.isNotEmpty) ...[
                    const Text(
                      'Etapas da jornada',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ..._steps.asMap().entries.map((entry) {
                      final i = entry.key;
                      final step = entry.value;
                      final completed = _isStepCompleted(step);
                      final current = _isStepCurrent(step);
                      final isLast = i == _steps.length - 1;

                      return _StepTile(
                        step: step,
                        completed: completed,
                        current: current,
                        isLast: isLast,
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  if (_templates.isNotEmpty) ...[
                    const Text(
                      'Intervenções do protocolo',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    ..._templates.map((t) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE7ECF1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.patient.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.task_alt_rounded, color: AppColors.patient, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                    if (t.goal.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(t.goal, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ],
                                ),
                              ),
                              Text('${t.estimatedMinutes} min', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        )),
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool small;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: small ? 12 : 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final Map<String, dynamic> step;
  final bool completed;
  final bool current;
  final bool isLast;

  const _StepTile({
    required this.step,
    required this.completed,
    required this.current,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !completed && !current;
    final color = completed
        ? AppColors.success
        : current
            ? AppColors.patient
            : AppColors.textSecondary.withValues(alpha: 0.3);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Linha vertical + bolinha
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: completed || current ? 0.15 : 0.07),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: current ? 2 : 1),
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_rounded
                        : current
                            ? Icons.play_arrow_rounded
                            : Icons.lock_outline_rounded,
                    size: 14,
                    color: color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed ? AppColors.success.withValues(alpha: 0.3) : const Color(0xFFE7ECF1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Conteúdo
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: current
                      ? AppColors.patient.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: current ? AppColors.patient.withValues(alpha: 0.3) : const Color(0xFFE7ECF1),
                    width: current ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step['title'] as String? ?? 'Fase ${step['phase']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: locked ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (current)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.patient.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Em andamento',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.patient),
                            ),
                          ),
                        if (completed)
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                      ],
                    ),
                    if (step['description'] != null && (step['description'] as String).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
