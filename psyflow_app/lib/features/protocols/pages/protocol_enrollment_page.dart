import 'package:flutter/material.dart';
import 'package:psyflow_app/core/theme/app_theme.dart';
import 'package:psyflow_app/core/theme/app_card.dart';
import 'package:psyflow_app/core/theme/app_dialog.dart';
import 'package:psyflow_app/core/theme/app_snackbar.dart';
import 'package:psyflow_app/core/theme/app_typography.dart';
import 'package:psyflow_app/models/therapeutic_protocol.dart';
import 'package:psyflow_app/core/services/protocol_service.dart';

class ProtocolEnrollmentPage extends StatefulWidget {
  final String patientId;
  final String? professionalId;

  const ProtocolEnrollmentPage({
    super.key,
    required this.patientId,
    this.professionalId,
  });

  @override
  State<ProtocolEnrollmentPage> createState() => _ProtocolEnrollmentPageState();
}

class _ProtocolEnrollmentPageState extends State<ProtocolEnrollmentPage> {
  final ProtocolService _service = ProtocolService();
  List<PatientProtocolEnrollment> _enrollments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() => _loading = true);
    try {
      _enrollments = await _service.getPatientEnrollments(widget.patientId);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Erro ao carregar protocolos: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meus Protocolos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _enrollments.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _enrollments.length,
                  itemBuilder: (context, index) {
                    final enrollment = _enrollments[index];
                    return _EnrollmentCard(
                      enrollment: enrollment,
                      onTap: () => _openEnrollmentDetail(enrollment),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhum protocolo ativo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Protocolos atribuídos pelo seu profissional aparecerão aqui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openEnrollmentDetail(PatientProtocolEnrollment enrollment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProtocolProgressPage(enrollmentId: enrollment.id),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final PatientProtocolEnrollment enrollment;
  final VoidCallback onTap;

  const _EnrollmentCard({
    required this.enrollment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment.protocolId,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Protocolo em andamento',
                  style: Theme.of(context).textTheme.titleMedium?.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(enrollment.progressPercent * 100).toInt()}% concluído',
                  style: Theme.of(context).textTheme.bodySmall?.muted,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class ProtocolProgressPage extends StatefulWidget {
  final String enrollmentId;

  const ProtocolProgressPage({super.key, required this.enrollmentId});

  @override
  State<ProtocolProgressPage> createState() => _ProtocolProgressPageState();
}

class _ProtocolProgressPageState extends State<ProtocolProgressPage> {
  final ProtocolService _service = ProtocolService();
  PatientProtocolEnrollment? _enrollment;
  TherapeuticProtocol? _protocol;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      _enrollment = await _service.getEnrollmentById(widget.enrollmentId);
      if (_enrollment != null) {
        _protocol = await _service.getProtocolById(_enrollment!.protocolId);
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Erro ao carregar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _enrollment == null || _protocol == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Progresso do Protocolo')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final specialtyColor = _getSpecialtyColor(_protocol!.specialty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_protocol!.name),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: specialtyColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(_getSpecialtyIcon(_protocol!.specialty), color: specialtyColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progresso Geral',
                            style: Theme.of(context).textTheme.bodySmall?.muted,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(_enrollment!.progressPercent * 100).toInt()}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: specialtyColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _getStatusLabel(_enrollment!.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(_enrollment!.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_enrollment!.currentStepIndex + 1} de ${_protocol!.steps.length} etapas',
                          style: Theme.of(context).textTheme.bodySmall?.muted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _enrollment!.progressPercent,
                  backgroundColor: AppColors.surfaceVariant,
                  color: specialtyColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          // Steps list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _protocol!.steps.length,
              itemBuilder: (context, index) {
                final step = _protocol!.steps[index];
                final progress = index < _enrollment!.stepProgress.length
                    ? _enrollment!.stepProgress[index]
                    : null;

                return _ProgressStepCard(
                  step: step,
                  progress: progress,
                  stepNumber: index + 1,
                  isCurrent: index == _enrollment!.currentStepIndex,
                  specialtyColor: specialtyColor,
                  onTap: progress?.isAvailable == true || progress?.isInProgress == true
                      ? () => _openStepDetail(step, progress!, index)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getSpecialtyColor(String specialty) {
    switch (specialty) {
      case 'psychology': return AppColors.psychology;
      case 'occupational_therapy': return AppColors.occupationalTherapy;
      case 'psychopedagogy': return AppColors.psychopedagogy;
      case 'speech_therapy': return AppColors.speechTherapy;
      case 'neuropsychology': return AppColors.neuropsychology;
      case 'psychiatry': return AppColors.psychiatry;
      default: return AppColors.primary;
    }
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'psychology': return Icons.psychology_rounded;
      case 'occupational_therapy': return Icons.accessibility_new_rounded;
      case 'psychopedagogy': return Icons.school_rounded;
      case 'speech_therapy': return Icons.record_voice_over_rounded;
      case 'neuropsychology': return Icons.psychology_rounded;
      case 'psychiatry': return Icons.medical_services_rounded;
      default: return Icons.menu_book_rounded;
    }
  }

  String _getStatusLabel(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.active: return 'Em Andamento';
      case EnrollmentStatus.paused: return 'Pausado';
      case EnrollmentStatus.completed: return 'Concluído';
      case EnrollmentStatus.cancelled: return 'Cancelado';
    }
  }

  Color _getStatusColor(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.active: return AppColors.success;
      case EnrollmentStatus.paused: return AppColors.warning;
      case EnrollmentStatus.completed: return AppColors.primary;
      case EnrollmentStatus.cancelled: return AppColors.error;
    }
  }

  void _openStepDetail(ProtocolStep step, StepProgress progress, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProtocolStepDetailPage(
          step: step,
          progress: progress,
          protocol: _protocol!,
          enrollment: _enrollment!,
          stepIndex: index,
        ),
      ),
    );
  }
}

class _ProgressStepCard extends StatelessWidget {
  final ProtocolStep step;
  final StepProgress? progress;
  final int stepNumber;
  final bool isCurrent;
  final Color specialtyColor;
  final VoidCallback? onTap;

  const _ProgressStepCard({
    required this.step,
    required this.progress,
    required this.stepNumber,
    required this.isCurrent,
    required this.specialtyColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = progress?.status ?? StepStatus.locked;
    final isCompleted = status == StepStatus.completed;
    final isInProgress = status == StepStatus.inProgress;
    final isAvailable = status == StepStatus.available;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case StepStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case StepStatus.inProgress:
        statusColor = specialtyColor;
        statusIcon = Icons.play_circle_rounded;
        break;
      case StepStatus.available:
        statusColor = AppColors.info;
        statusIcon = Icons.lock_open_rounded;
        break;
      case StepStatus.locked:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.lock_rounded;
        break;
      case StepStatus.skipped:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.skip_next_rounded;
        break;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      border: isCurrent ? Border.all(color: specialtyColor, width: 2) : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Semana ${step.weekNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: specialtyColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: specialtyColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ATUAL',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: specialtyColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleSmall?.semiBold,
                ),
                const SizedBox(height: 4),
                if (progress != null && progress.completionPercent > 0)
                  LinearProgressIndicator(
                    value: progress.completionPercent / 100,
                    backgroundColor: AppColors.surfaceVariant,
                    color: statusColor,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  )
                else
                  Text(
                    _getStepStatusText(status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statusColor),
                  ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  String _getStepStatusText(StepStatus status) {
    switch (status) {
      case StepStatus.completed: return 'Concluído';
      case StepStatus.inProgress: return 'Em andamento';
      case StepStatus.available: return 'Disponível';
      case StepStatus.locked: return 'Bloqueado';
      case StepStatus.skipped: return 'Pulado';
    }
  }
}

class ProtocolStepDetailPage extends StatefulWidget {
  final ProtocolStep step;
  final StepProgress progress;
  final TherapeuticProtocol protocol;
  final PatientProtocolEnrollment enrollment;
  final int stepIndex;

  const ProtocolStepDetailPage({
    super.key,
    required this.step,
    required this.progress,
    required this.protocol,
    required this.enrollment,
    required this.stepIndex,
  });

  @override
  State<ProtocolStepDetailPage> createState() => _ProtocolStepDetailPageState();
}

class _ProtocolStepDetailPageState extends State<ProtocolStepDetailPage> {
  final ProtocolService _service = ProtocolService();

  @override
  Widget build(BuildContext context) {
    final specialtyColor = _getSpecialtyColor(widget.protocol.specialty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Semana ${widget.step.weekNumber}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step header
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: specialtyColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Semana ${widget.step.weekNumber}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: specialtyColor),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.progress.status).withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusLabel(widget.progress.status),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getStatusColor(widget.progress.status)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(widget.step.title, style: Theme.of(context).textTheme.titleLarge?.semiBold),
                  const SizedBox(height: 8),
                  Text(widget.step.description, style: Theme.of(context).textTheme.bodyMedium?.muted),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Objectives
            if (widget.step.objectives.isNotEmpty) ...[
              Text('Objetivos da Semana', style: Theme.of(context).textTheme.titleMedium?.semiBold),
              const SizedBox(height: 12),
              ...widget.step.objectives.map((o) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, color: specialtyColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(o, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],

            // Interventions
            Text('Intervenções', style: Theme.of(context).textTheme.titleMedium?.semiBold),
            const SizedBox(height: 12),
            ...widget.step.interventionIds.map((interventionId) => _InterventionCard(
              interventionId: interventionId,
              step: widget.step,
              enrollment: widget.enrollment,
              stepIndex: widget.stepIndex,
              specialtyColor: specialtyColor,
              onComplete: () => _completeIntervention(interventionId),
            )),
            const SizedBox(height: 24),

            // Actions
            if (widget.progress.isAvailable && !widget.progress.isInProgress)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _startStep(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Iniciar Etapa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: specialtyColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            else if (widget.progress.isInProgress && !widget.progress.isCompleted)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _completeStep(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Concluir Etapa'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            else if (widget.progress.isCompleted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration_rounded, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'Etapa concluída! Parabéns!',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSpecialtyColor(String specialty) {
    switch (specialty) {
      case 'psychology': return AppColors.psychology;
      case 'occupational_therapy': return AppColors.occupationalTherapy;
      case 'psychopedagogy': return AppColors.psychopedagogy;
      case 'speech_therapy': return AppColors.speechTherapy;
      case 'neuropsychology': return AppColors.neuropsychology;
      case 'psychiatry': return AppColors.psychiatry;
      default: return AppColors.primary;
    }
  }

  Color _getStatusColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed: return AppColors.success;
      case StepStatus.inProgress: return _getSpecialtyColor(widget.protocol.specialty);
      case StepStatus.available: return AppColors.info;
      case StepStatus.locked: return AppColors.textMuted;
      case StepStatus.skipped: return AppColors.textMuted;
    }
  }

  String _getStatusLabel(StepStatus status) {
    switch (status) {
      case StepStatus.completed: return 'Concluído';
      case StepStatus.inProgress: return 'Em Andamento';
      case StepStatus.available: return 'Disponível';
      case StepStatus.locked: return 'Bloqueado';
      case StepStatus.skipped: return 'Pulado';
    }
  }

  Future<void> _startStep() async {
    try {
      await _service.updateStepProgress(
        enrollmentId: widget.enrollment.id,
        stepIndex: widget.stepIndex,
        progress: StepProgress(
          stepId: widget.step.id,
          stepOrder: widget.step.order,
          status: StepStatus.inProgress,
          startedAt: DateTime.now(),
        ),
      );
      if (mounted) setState(() {});
      AppSnackBar.success(context, 'Etapa iniciada!');
    } catch (e) {
      AppSnackBar.error(context, 'Erro: $e');
    }
  }

  Future<void> _completeStep() async {
    try {
      await _service.updateStepProgress(
        enrollmentId: widget.enrollment.id,
        stepIndex: widget.stepIndex,
        progress: StepProgress(
          stepId: widget.step.id,
          stepOrder: widget.step.order,
          status: StepStatus.completed,
          startedAt: widget.progress.startedAt,
          completedAt: DateTime.now(),
          completionPercent: 100,
        ),
      );
      if (mounted) {
        AppSnackBar.success(context, 'Etapa concluída com sucesso!');
        Navigator.pop(context);
      }
    } catch (e) {
      AppSnackBar.error(context, 'Erro: $e');
    }
  }

  Future<void> _completeIntervention(String interventionId) async {
    try {
      await _service.recordInterventionResult(
        enrollmentId: widget.enrollment.id,
        stepIndex: widget.stepIndex,
        interventionId: interventionId,
        result: {'completed': true, 'completed_at': DateTime.now().toIso8601String()},
      );
      if (mounted) {
        AppSnackBar.success(context, 'Intervenção registrada!');
        setState(() {});
      }
    } catch (e) {
      AppSnackBar.error(context, 'Erro: $e');
    }
  }
}

class _InterventionCard extends StatelessWidget {
  final String interventionId;
  final ProtocolStep step;
  final PatientProtocolEnrollment enrollment;
  final int stepIndex;
  final Color specialtyColor;
  final VoidCallback onComplete;

  const _InterventionCard({
    required this.interventionId,
    required this.step,
    required this.enrollment,
    required this.stepIndex,
    required this.specialtyColor,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = enrollment.stepProgress[stepIndex].interventionResults[interventionId]?['completed'] == true;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.success.withAlpha(30) : specialtyColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.psychology_rounded,
              color: isCompleted ? AppColors.success : specialtyColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interventionId.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                  style: Theme.of(context).textTheme.bodyMedium?.semiBold,
                ),
                Text(
                  'Intervenção da etapa',
                  style: Theme.of(context).textTheme.bodySmall?.muted,
                ),
              ],
            ),
          ),
          if (!isCompleted)
            FilledButton.tonal(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: specialtyColor.withAlpha(30),
                foregroundColor: specialtyColor,
              ),
              child: const Text('Realizar'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Concluído', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}