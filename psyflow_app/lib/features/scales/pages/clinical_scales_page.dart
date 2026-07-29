import 'package:flutter/material.dart';
import 'package:psyflow_app/core/theme/app_theme.dart';
import 'package:psyflow_app/core/theme/app_card.dart';
import 'package:psyflow_app/core/theme/app_dialog.dart';
import 'package:psyflow_app/core/theme/app_snackbar.dart';
import 'package:psyflow_app/core/theme/app_typography.dart';
import 'package:psyflow_app/models/clinical_scale_model.dart';
import 'package:psyflow_app/core/services/clinical_scale_service.dart';

class ClinicalScalesPage extends StatefulWidget {
  const ClinicalScalesPage({super.key});

  @override
  State<ClinicalScalesPage> createState() => _ClinicalScalesPageState();
}

class _ClinicalScalesPageState extends State<ClinicalScalesPage> {
  final ClinicalScaleService _service = ClinicalScaleService();
  List<ClinicalScaleModel> _scales = [];
  bool _loading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadScales();
  }

  Future<void> _loadScales() async {
    setState(() => _loading = true);
    try {
      _scales = _service.getAllScales();
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erro ao carregar escalas: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _categories {
    final cats = _scales.map((s) => s.category.label).toSet().toList();
    cats.sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Escalas Clínicas'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // Category filter
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'Todas',
                        selected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      ..._categories.map((cat) => _CategoryChip(
                        label: cat,
                        selected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      )),
                    ],
                  ),
                ),
                // Scales list
                Expanded(
                  child: _filteredScales.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredScales.length,
                          itemBuilder: (context, index) {
                            final scale = _filteredScales[index];
                            return _ScaleCard(
                              scale: scale,
                              onTap: () => _openScale(scale),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  List<ClinicalScaleModel> get _filteredScales {
    if (_selectedCategory == null) return _scales;
    return _scales.where((s) => s.category.label == _selectedCategory).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assessment_outlined, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhuma escala encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _openScale(ClinicalScaleModel scale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScaleApplicationPage(scale: scale),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _ScaleCard extends StatelessWidget {
  final ClinicalScaleModel scale;
  final VoidCallback onTap;

  const _ScaleCard({
    required this.scale,
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
              color: _getCategoryColor(scale.category).withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(scale.category),
              color: _getCategoryColor(scale.category),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scale.code,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(scale.category),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  scale.title,
                  style: Theme.of(context).textTheme.titleMedium?.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${scale.questions.length} perguntas • ${scale.category.label}',
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

  Color _getCategoryColor(ScaleCategory category) {
    switch (category) {
      case ScaleCategory.depression:
        return AppColors.error;
      case ScaleCategory.anxiety:
        return AppColors.warning;
      case ScaleCategory.adhd:
        return AppColors.info;
      case ScaleCategory.occupationalRoutine:
        return AppColors.occupationalTherapy;
      case ScaleCategory.cognitiveDevelopment:
        return AppColors.psychopedagogy;
      case ScaleCategory.general:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(ScaleCategory category) {
    switch (category) {
      case ScaleCategory.depression:
        return Icons.sentiment_very_dissatisfied_rounded;
      case ScaleCategory.anxiety:
        return Icons.psychology_rounded;
      case ScaleCategory.adhd:
        return Icons.speed_rounded;
      case ScaleCategory.occupationalRoutine:
        return Icons.schedule_rounded;
      case ScaleCategory.cognitiveDevelopment:
        return Icons.lightbulb_outline_rounded;
      case ScaleCategory.general:
        return Icons.assessment_rounded;
    }
  }
}

class ScaleApplicationPage extends StatefulWidget {
  final ClinicalScaleModel scale;

  const ScaleApplicationPage({super.key, required this.scale});

  @override
  State<ScaleApplicationPage> createState() => _ScaleApplicationPageState();
}

class _ScaleApplicationPageState extends State<ScaleApplicationPage> {
  final ClinicalScaleService _service = ClinicalScaleService();
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;
  String? _patientId;
  String? _professionalId;

  @override
  void initState() {
    super.initState();
    // TODO: Get patient/professional IDs from context
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.scale.code),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questão ${_answers.length + 1} de ${widget.scale.questions.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.semiBold,
                    ),
                    Text(
                      '${((_answers.length / widget.scale.questions.length) * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _answers.length / widget.scale.questions.length,
                  backgroundColor: AppColors.surfaceVariant,
                  color: AppColors.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          // Questions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.scale.questions.length,
              itemBuilder: (context, index) {
                final question = widget.scale.questions[index];
                final isAnswered = _answers.containsKey(question.id);
                final isCurrent = !isAnswered && _answers.length == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent ? AppColors.primary : AppColors.surfaceVariant,
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(30),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isAnswered
                                  ? AppColors.success
                                  : (isCurrent ? AppColors.primary : AppColors.surfaceVariant),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isAnswered
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : Text(
                                      '${question.id}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isCurrent ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.text,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isAnswered ? AppColors.textSecondary : AppColors.textPrimary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (!isAnswered) ...[
                        const SizedBox(height: 16),
                        ...question.options.asMap().entries.map((entry) {
                          final optionIndex = entry.key;
                          final optionText = entry.value;
                          final optionValue = question.optionValues[optionIndex];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => _selectAnswer(question.id, optionValue),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.surfaceVariant),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.primary, width: 2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        optionText,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ] else ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Respondida: ${_getSelectedOptionText(question, _answers[question.id]!)}',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _removeAnswer(question.id),
                                child: const Text('Alterar'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // Submit button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _answers.length == widget.scale.questions.length ? _submitScale : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Finalizar Escala',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int questionId, int value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  void _removeAnswer(int questionId) {
    setState(() {
      _answers.remove(questionId);
    });
  }

  String _getSelectedOptionText(ClinicalScaleQuestion question, int value) {
    final index = question.optionValues.indexOf(value);
    if (index >= 0 && index < question.options.length) {
      return question.options[index];
    }
    return value.toString();
  }

  Future<void> _submitScale() async {
    if (_patientId == null || _professionalId == null) {
      AppSnackBar.error(context, 'Erro: IDs de paciente/profissional não encontrados');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int totalScore = 0;
      for (final question in widget.scale.questions) {
        final answer = _answers[question.id] ?? 0;
        totalScore += answer;
      }

      String interpretation = _getInterpretation(widget.scale.code, totalScore);

      await _service.submitScaleResponse(
        scaleId: widget.scale.id,
        scaleCode: widget.scale.code,
        patientId: _patientId!,
        professionalId: _professionalId!,
        answers: _answers,
        totalScore: totalScore,
        severityInterpretation: interpretation,
      );

      if (mounted) {
        AppSnackBar.success(context, 'Escala enviada com sucesso!');
        _showResultDialog(totalScore, interpretation);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erro ao enviar escala: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getInterpretation(String scaleCode, int score) {
    switch (scaleCode) {
      case 'PHQ-9':
        if (score <= 4) return 'Depressão mínima';
        if (score <= 9) return 'Depressão leve';
        if (score <= 14) return 'Depressão moderada';
        if (score <= 19) return 'Depressão moderadamente grave';
        return 'Depressão grave';
      case 'GAD-7':
        if (score <= 4) return 'Ansiedade mínima';
        if (score <= 9) return 'Ansiedade leve';
        if (score <= 14) return 'Ansiedade moderada';
        return 'Ansiedade grave';
      case 'BDI-II':
        if (score <= 13) return 'Depressão mínima';
        if (score <= 19) return 'Depressão leve';
        if (score <= 28) return 'Depressão moderada';
        return 'Depressão grave';
      default:
        return 'Pontuação: $score';
    }
  }

  void _showResultDialog(int score, String interpretation) {
    AppDialog.show(
      context: context,
      title: 'Resultado da ${widget.scale.code}',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getResultColor(score).withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _getResultColor(score),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            interpretation,
            style: Theme.of(context).textTheme.titleMedium?.semiBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pontuação total: $score',
            style: Theme.of(context).textTheme.bodyMedium?.muted,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Color _getResultColor(int score) {
    // Simplified - in real app would depend on scale
    if (score <= 4) return AppColors.success;
    if (score <= 9) return AppColors.warning;
    if (score <= 14) return AppColors.warning;
    return AppColors.error;
  }
}

class ScaleResultsPage extends StatefulWidget {
  final String patientId;

  const ScaleResultsPage({super.key, required this.patientId});

  @override
  State<ScaleResultsPage> createState() => _ScaleResultsPageState();
}

class _ScaleResultsPageState extends State<ScaleResultsPage> {
  final ClinicalScaleService _service = ClinicalScaleService();
  List<ClinicalScaleResponseModel> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _loading = true);
    try {
      _results = await _service.getPatientScaleResponses(widget.patientId);
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Erro ao carregar resultados: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resultados das Escalas'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _results.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return _ResultCard(result: result);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assessment_outlined, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado de escala',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'As escalas aplicadas aparecerão aqui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ClinicalScaleResponseModel result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(result.severityInterpretation);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: severityColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assessment_rounded,
                  color: severityColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.scaleCode,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: severityColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(result.completedAt),
                      style: Theme.of(context).textTheme.bodySmall?.muted,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result.totalScore}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: severityColor,
                        ),
                    ),
                  Text(
                    'pontos',
                    style: Theme.of(context).textTheme.bodySmall?.muted,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: severityColor.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: severityColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.severityInterpretation,
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String interpretation) {
    final lower = interpretation.toLowerCase();
    if (lower.contains('grave') || lower.contains('severa')) return AppColors.error;
    if (lower.contains('moderada')) return AppColors.warning;
    if (lower.contains('leve')) return AppColors.info;
    return AppColors.success;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}