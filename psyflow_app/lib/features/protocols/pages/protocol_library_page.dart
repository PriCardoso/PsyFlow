import 'package:flutter/material.dart';
import 'package:psyflow_app/core/theme/app_theme.dart';
import 'package:psyflow_app/core/theme/app_card.dart';
import 'package:psyflow_app/core/theme/app_dialog.dart';
import 'package:psyflow_app/core/theme/app_snackbar.dart';
import 'package:psyflow_app/core/theme/app_typography.dart';
import 'package:psyflow_app/models/therapeutic_protocol.dart';
import 'package:psyflow_app/models/intervention_template.dart';
import 'package:psyflow_app/core/services/protocol_service.dart';

class ProtocolLibraryPage extends StatefulWidget {
  const ProtocolLibraryPage({super.key});

  @override
  State<ProtocolLibraryPage> createState() => _ProtocolLibraryPageState();
}

class _ProtocolLibraryPageState extends State<ProtocolLibraryPage> {
  final ProtocolService _service = ProtocolService();
  List<TherapeuticProtocol> _protocols = [];
  bool _loading = true;
  String? _selectedSpecialty;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadProtocols();
  }

  Future<void> _loadProtocols() async {
    setState(() => _loading = true);
    try {
      _protocols = await _service.getActiveProtocols(specialty: _selectedSpecialty);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Erro ao carregar protocolos: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _specialties {
    final specs = _protocols.map((p) => p.specialty).toSet().toList();
    specs.sort();
    return specs;
  }

  String _getSpecialtyLabel(String specialty) {
    switch (specialty) {
      case 'psychology':
        return 'Psicologia';
      case 'occupational_therapy':
        return 'Terapia Ocupacional';
      case 'psychopedagogy':
        return 'Psicopedagogia';
      case 'speech_therapy':
        return 'Fonoaudiologia';
      case 'neuropsychology':
        return 'Neuropsicologia';
      case 'psychiatry':
        return 'Psiquiatria';
      default:
        return specialty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Biblioteca de Protocolos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Search and filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText: 'Buscar protocolo...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _SpecialtyChip(
                              label: 'Todas',
                              selected: _selectedSpecialty == null,
                              onTap: () => setState(() => _selectedSpecialty = null),
                            ),
                            ..._specialties.map((s) => _SpecialtyChip(
                              label: _getSpecialtyLabel(s),
                              selected: _selectedSpecialty == s,
                              onTap: () => setState(() => _selectedSpecialty = s),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Protocols list
                Expanded(
                  child: _filteredProtocols.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProtocols.length,
                          itemBuilder: (context, index) {
                            final protocol = _filteredProtocols[index];
                            return _ProtocolCard(
                              protocol: protocol,
                              onTap: () => _openProtocolDetail(protocol),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  List<TherapeuticProtocol> get _filteredProtocols {
    var result = _protocols;
    if (_search.isNotEmpty) {
      result = result.where((p) =>
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.description.toLowerCase().contains(_search.toLowerCase()) ||
          p.targetConditions.any((c) => c.toLowerCase().contains(_search.toLowerCase()))).toList();
    }
    return result;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhum protocolo encontrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _openProtocolDetail(TherapeuticProtocol protocol) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProtocolDetailPage(protocol: protocol),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SpecialtyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.surfaceVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  final TherapeuticProtocol protocol;
  final VoidCallback onTap;

  const _ProtocolCard({
    required this.protocol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final specialtyColor = _getSpecialtyColor(protocol.specialty);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: specialtyColor.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getSpecialtyIcon(protocol.specialty),
              color: specialtyColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(protocol.difficultyLevel).withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        protocol.difficultyLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getDifficultyColor(protocol.difficultyLevel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${protocol.estimatedWeeks} semanas',
                      style: Theme.of(context).textTheme.bodySmall?.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  protocol.name,
                  style: Theme.of(context).textTheme.titleMedium?.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  protocol.description,
                  style: Theme.of(context).textTheme.bodySmall?.muted,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: protocol.targetConditions.take(3).map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Color _getSpecialtyColor(String specialty) {
    switch (specialty) {
      case 'psychology':
        return AppColors.psychology;
      case 'occupational_therapy':
        return AppColors.occupationalTherapy;
      case 'psychopedagogy':
        return AppColors.psychopedagogy;
      case 'speech_therapy':
        return AppColors.speechTherapy;
      case 'neuropsychology':
        return AppColors.neuropsychology;
      case 'psychiatry':
        return AppColors.psychiatry;
      default:
        return AppColors.primary;
    }
  }

  IconData _getSpecialtyIcon(String specialty) {
    switch (specialty) {
      case 'psychology':
        return Icons.psychology_rounded;
      case 'occupational_therapy':
        return Icons.accessibility_new_rounded;
      case 'psychopedagogy':
        return Icons.school_rounded;
      case 'speech_therapy':
        return Icons.record_voice_over_rounded;
      case 'neuropsychology':
        return Icons.psychology_rounded;
      case 'psychiatry':
        return Icons.medical_services_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}

class ProtocolDetailPage extends StatefulWidget {
  final TherapeuticProtocol protocol;

  const ProtocolDetailPage({super.key, required this.protocol});

  @override
  State<ProtocolDetailPage> createState() => _ProtocolDetailPageState();
}

class _ProtocolDetailPageState extends State<ProtocolDetailPage> {
  final ProtocolService _service = ProtocolService();

  @override
  Widget build(BuildContext context) {
    final specialtyColor = _getSpecialtyColor(widget.protocol.specialty);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: specialtyColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [specialtyColor, specialtyColor.withAlpha(200)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getSpecialtyLabel(widget.protocol.specialty),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.protocol.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.schedule_rounded,
                              label: '${widget.protocol.estimatedWeeks} semanas',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.assignment_rounded,
                              label: '${widget.protocol.totalSteps} etapas',
                            ),
                            const SizedBox(width: 8),
                            _InfoChip(
                              icon: Icons.trending_up_rounded,
                              label: widget.protocol.difficultyLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Description
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descrição', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                      const SizedBox(height: 8),
                      Text(widget.protocol.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Target conditions
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Indicações', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.protocol.targetConditions.map((c) => Chip(
                          label: Text(c),
                          backgroundColor: specialtyColor.withAlpha(30),
                          labelStyle: TextStyle(color: specialtyColor),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Steps
                Text('Etapas do Protocolo', style: Theme.of(context).textTheme.titleMedium?.semiBold),
                const SizedBox(height: 12),
                ...widget.protocol.steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return _StepCard(
                    step: step,
                    stepNumber: index + 1,
                    totalSteps: widget.protocol.steps.length,
                    specialtyColor: specialtyColor,
                    interventions: _getInterventionsForStep(step),
                  );
                }),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _assignProtocol(),
                        icon: const Icon(Icons.person_add_rounded),
                        label: const Text('Atribuir a Paciente'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: specialtyColor,
                          side: BorderSide(color: specialtyColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _createCustomProtocol(),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Personalizar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: specialtyColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<InterventionTemplate> _getInterventionsForStep(ProtocolStep step) {
    // In a real app, this would fetch from the intervention library
    return step.interventionIds.map((id) => InterventionTemplate(
      id: id,
      title: id.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
      description: '',
      category: '',
      specialty: widget.protocol.specialty,
      technique: '',
      goal: '',
      reflectionQuestion: '',
      difficultyLevel: 1,
      estimatedMinutes: 15,
      phase: 1,
    )).toList();
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

  String _getSpecialtyLabel(String specialty) {
    switch (specialty) {
      case 'psychology': return 'Psicologia';
      case 'occupational_therapy': return 'Terapia Ocupacional';
      case 'psychopedagogy': return 'Psicopedagogia';
      case 'speech_therapy': return 'Fonoaudiologia';
      case 'neuropsychology': return 'Neuropsicologia';
      case 'psychiatry': return 'Psiquiatria';
      default: return specialty;
    }
  }

  void _assignProtocol() {
    // TODO: Show patient selection dialog
    AppSnackBar.info(context, 'Seleção de paciente será implementada');
  }

  void _createCustomProtocol() {
    // TODO: Navigate to protocol builder
    AppSnackBar.info(context, 'Construtor de protocolo personalizado será implementado');
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final ProtocolStep step;
  final int stepNumber;
  final int totalSteps;
  final Color specialtyColor;
  final List<InterventionTemplate> interventions;

  const _StepCard({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    required this.specialtyColor,
    required this.interventions,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: specialtyColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semana ${step.weekNumber} • Etapa $stepNumber de $totalSteps',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: specialtyColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      step.title,
                      style: Theme.of(context).textTheme.titleMedium?.semiBold,
                    ),
                  ],
                ),
              ),
              if (step.isOptional)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Opcional',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(step.description, style: Theme.of(context).textTheme.bodyMedium?.muted),
          if (step.objectives.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Objetivos:', style: Theme.of(context).textTheme.labelMedium?.semiBold),
            const SizedBox(height: 4),
            ...step.objectives.map((o) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 14, color: specialtyColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(o, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            )),
          ],
          if (interventions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Intervenções:', style: Theme.of(context).textTheme.labelMedium?.semiBold),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interventions.map((i) => Chip(
                label: Text(i.title, style: const TextStyle(fontSize: 11)),
                backgroundColor: specialtyColor.withAlpha(20),
                labelStyle: TextStyle(color: specialtyColor, fontWeight: FontWeight.w500),
                side: BorderSide(color: specialtyColor.withAlpha(50)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}