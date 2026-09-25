import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/task_item.dart';
import '../../data/task_catalog.dart';

class TaskExecutionPage extends StatefulWidget {
  final TaskItem task;

  const TaskExecutionPage({super.key, required this.task});

  @override
  State<TaskExecutionPage> createState() => _TaskExecutionPageState();
}

class _TaskExecutionPageState extends State<TaskExecutionPage> {
  final _taskService = sl<TaskService>();
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};

  int _currentStepIndex = 0;
  bool _savingDraft = false;
  bool _submitting = false;
  bool _showSuccessScreen = false;
  int _moodBefore = 5;
  int _moodAfter = 5;

  late List<TaskFormFieldConfig> _fields;

  @override
  void initState() {
    super.initState();
    _fields = widget.task.formFields;
    _moodBefore = widget.task.moodBefore ?? 5;
    _moodAfter = widget.task.moodAfter ?? 5;

    // Restaurar rascunho se existir
    final savedValues = widget.task.patientValues;
    for (final field in _fields) {
      final key = 'campo_${field.ordem}';
      if (savedValues.containsKey(key)) {
        _answers[key] = savedValues[key];
      } else if (field.tipo == 'escala_linear') {
        _answers[key] = field.min ?? 1;
      }
    }

    // Se for formulário clássico sem campos específicos
    if (_fields.isEmpty && widget.task.patientResponse != null) {
      _answers['resposta'] = widget.task.patientResponse;
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String key, String initialText) {
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController(text: initialText);
    }
    return _textControllers[key]!;
  }

  Future<void> _saveDraft() async {
    setState(() => _savingDraft = true);
    try {
      // Coletar textos pendentes dos controllers
      for (final entry in _textControllers.entries) {
        _answers[entry.key] = entry.value.text.trim();
      }

      await _taskService.saveDraftTask(
        taskId: widget.task.id,
        formValues: _answers,
        moodBefore: _moodBefore,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rascunho salvo com sucesso! Você pode continuar a qualquer momento.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar rascunho: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _savingDraft = false);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      for (final entry in _textControllers.entries) {
        _answers[entry.key] = entry.value.text.trim();
      }

      final summaryBuffer = StringBuffer();
      for (final f in _fields) {
        final val = _answers['campo_${f.ordem}'];
        if (val != null && val.toString().isNotEmpty) {
          summaryBuffer.writeln('${f.label}: $val');
        }
      }

      await _taskService.completeTaskWithForm(
        taskId: widget.task.id,
        formValues: _answers,
        textSummary: summaryBuffer.isNotEmpty ? summaryBuffer.toString().trim() : null,
        moodBefore: _moodBefore,
        moodAfter: _moodAfter,
      );

      if (mounted) {
        setState(() {
          _submitting = false;
          _showSuccessScreen = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar atividade: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccessScreen) {
      return _buildSuccessScreen();
    }

    final isChild = widget.task.faixaEtaria.toLowerCase().contains('criança');
    final isSenior = widget.task.faixaEtaria.toLowerCase().contains('idoso');
    final totalSteps = _fields.isEmpty ? 1 : _fields.length;
    final progress = (totalSteps > 0) ? ((_currentStepIndex + 1) / totalSteps) : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isSenior ? 17 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _savingDraft ? null : _saveDraft,
            icon: _savingDraft
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.patient))
                : const Icon(Icons.bookmark_border_rounded, size: 18, color: AppColors.patient),
            label: Text(
              'Salvar Rascunho',
              style: TextStyle(
                color: AppColors.patient,
                fontWeight: FontWeight.w700,
                fontSize: isSenior ? 14 : 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Progresso Progressiva
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Passo ${_currentStepIndex + 1} de $totalSteps',
                        style: TextStyle(
                          fontSize: isSenior ? 14 : 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}% concluído',
                        style: TextStyle(
                          fontSize: isSenior ? 14 : 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.patient,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: isChild ? 10 : 6,
                      backgroundColor: AppColors.patient.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.patient),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo da Pergunta / Campo Atual
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: _fields.isEmpty ? _buildFreeTextForm(isSenior) : _buildCurrentFieldForm(isChild, isSenior),
              ),
            ),

            // Barra de Ação Inferior (Anterior / Próximo / Concluir)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStepIndex > 0) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () => setState(() => _currentStepIndex--),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.patient,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _submitting
                            ? null
                            : () {
                                if (_currentStepIndex < totalSteps - 1) {
                                  setState(() => _currentStepIndex++);
                                } else {
                                  _submit();
                                }
                              },
                        child: _submitting
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                _currentStepIndex < totalSteps - 1 ? 'Próxima Pergunta →' : 'Concluir e Enviar ✨',
                                style: TextStyle(
                                  fontSize: isSenior ? 17 : 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // FORMULÁRIO DO CAMPO ATUAL
  // =========================================================================
  Widget _buildCurrentFieldForm(bool isChild, bool isSenior) {
    final field = _fields[_currentStepIndex];
    final key = 'campo_${field.ordem}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instruções gerais no primeiro passo
        if (_currentStepIndex == 0 && widget.task.description != null && widget.task.description!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.patient.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.patient.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.patient, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.task.description!,
                    style: TextStyle(
                      fontSize: isSenior ? 14 : 12.5,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Título da Pergunta
        Text(
          field.label,
          style: TextStyle(
            fontSize: isSenior ? 20 : (isChild ? 19 : 17),
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),

        // Widget específico por tipo de campo
        if (field.tipo == 'escala_linear') ...[
          _buildLinearScaleInput(field, key, isSenior),
        ] else if (field.tipo == 'emoji_picker') ...[
          _buildEmojiPickerInput(field, key),
        ] else if (field.tipo == 'selecao_unica') ...[
          _buildSingleChoiceInput(field, key, isSenior),
        ] else ...[
          _buildTextInput(field, key, isSenior),
        ],
      ],
    );
  }

  Widget _buildLinearScaleInput(TaskFormFieldConfig field, String key, bool isSenior) {
    final minVal = field.min ?? 1;
    final maxVal = field.max ?? 10;
    final currentVal = (_answers[key] as num?)?.toInt() ?? minVal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  field.labelMin ?? 'Mínimo ($minVal)',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.patient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$currentVal / $maxVal',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  field.labelMax ?? 'Máximo ($maxVal)',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.patient,
              thumbColor: AppColors.patient,
              inactiveTrackColor: AppColors.background,
              overlayColor: AppColors.patient.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: currentVal.toDouble(),
              min: minVal.toDouble(),
              max: maxVal.toDouble(),
              divisions: maxVal - minVal,
              onChanged: (v) {
                setState(() {
                  _answers[key] = v.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPickerInput(TaskFormFieldConfig field, String key) {
    final selectedOption = _answers[key] as String?;
    final options = field.options ?? ['😄 Muito Feliz', '🙂 Bem/Calmo', '😐 Mais ou menos', '😢 Triste', '😡 Bravo/Irritado', '😨 Assustado'];

    return Column(
      children: options.map((opt) {
        final selected = selectedOption == opt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _answers[key] = opt),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: selected ? AppColors.patient.withValues(alpha: 0.12) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.patient : const Color(0xFFE2E8F0),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      opt,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.check_circle_rounded, color: AppColors.patient, size: 22),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleChoiceInput(TaskFormFieldConfig field, String key, bool isSenior) {
    final selectedValue = _answers[key];
    final options = field.options ?? [];

    return Column(
      children: options.asMap().entries.map((entry) {
        final opt = entry.value;
        final optVal = (field.optionValues != null && field.optionValues!.length > entry.key)
            ? field.optionValues![entry.key]
            : opt;
        final isSelected = selectedValue == optVal || selectedValue == opt;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _answers[key] = optVal),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.patient.withValues(alpha: 0.12) : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.patient : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.patient : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.patient : AppColors.textSecondary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: isSenior ? 15.5 : 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(TaskFormFieldConfig field, String key, bool isSenior) {
    final controller = _getController(key, _answers[key] as String? ?? '');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: field.tipo == 'texto_curto' ? 1 : 6,
        style: TextStyle(fontSize: isSenior ? 16 : 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: field.placeholder ?? 'Escreva sua reflexão ou resposta aqui...',
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          contentPadding: const EdgeInsets.all(18),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFreeTextForm(bool isSenior) {
    final controller = _getController('resposta', _answers['resposta'] as String? ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
          Text(
            widget.task.description!,
            style: TextStyle(fontSize: isSenior ? 15 : 13.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          'Sua reflexão / resposta:',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 8,
            style: TextStyle(fontSize: isSenior ? 16 : 14),
            decoration: const InputDecoration(
              hintText: 'Escreva como foi sua experiência, o que sentiu e o que aprendeu...',
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              contentPadding: EdgeInsets.all(18),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // TELA 3: SUCESSO E REFORÇO POSITIVO ACOLHEDOR
  // =========================================================================
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animação/Ícone de Sucesso
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.success, Color(0xFF10B981)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 54),
              ),
              const SizedBox(height: 32),

              const Text(
                'Excelente Trabalho! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Você concluiu sua atividade e deu mais um passo importante no seu processo terapêutico.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              if (widget.task.isSessionRestricted)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.purple, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sua resposta foi guardada com segurança e será aberta junto ao seu psicólogo durante a sessão.',
                          style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patient,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Voltar para Minhas Tarefas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
