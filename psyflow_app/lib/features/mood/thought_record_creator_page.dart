import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/thought_record_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/thought_record_model.dart';

class ThoughtRecordCreatorPage extends StatefulWidget {
  const ThoughtRecordCreatorPage({super.key});

  @override
  State<ThoughtRecordCreatorPage> createState() => _ThoughtRecordCreatorPageState();
}

class _ThoughtRecordCreatorPageState extends State<ThoughtRecordCreatorPage> {
  final _service = sl<ThoughtRecordService>();
  int _currentStep = 0;
  bool _saving = false;
  bool _showCelebration = false;

  // 1. Situação & Gatilho
  final _situationController = TextEditingController();
  final _locationController = TextEditingController();
  final _triggerController = TextEditingController();
  final List<String> _selectedTags = [];

  final List<String> _suggestedTags = [
    'Trabalho', 'Família', 'Relacionamento', 'Estudos',
    'Saúde', 'Finanças', 'Amigos', 'Autoimagem', 'Futuro'
  ];

  // 2. Emoções Sentidas
  final List<EmotionIntensityItem> _selectedEmotions = [];

  // 3. Pensamentos Automáticos
  final _automaticThoughtController = TextEditingController();
  int _beliefInitial = 80;

  // 4. Distorções Cognitivas
  final List<String> _selectedDistortions = [];

  // 5. Desafio & Resposta Racional
  final _evidenceForController = TextEditingController();
  final _evidenceAgainstController = TextEditingController();
  final _rationalResponseController = TextEditingController();
  int _beliefFinal = 30;
  final Map<String, int> _finalEmotionIntensities = {};
  final _behaviorController = TextEditingController();

  @override
  void dispose() {
    _situationController.dispose();
    _locationController.dispose();
    _triggerController.dispose();
    _automaticThoughtController.dispose();
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    _rationalResponseController.dispose();
    _behaviorController.dispose();
    super.dispose();
  }

  void _toggleEmotion(Map<String, dynamic> e) {
    final name = e['name'] as String;
    final emoji = e['emoji'] as String;
    final idx = _selectedEmotions.indexWhere((item) => item.name == name);

    setState(() {
      if (idx >= 0) {
        _selectedEmotions.removeAt(idx);
        _finalEmotionIntensities.remove(name);
      } else {
        _selectedEmotions.add(EmotionIntensityItem(name: name, emoji: emoji, initialIntensity: 75));
        _finalEmotionIntensities[name] = 30;
      }
    });
  }

  void _toggleDistortion(String id) {
    setState(() {
      if (_selectedDistortions.contains(id)) {
        _selectedDistortions.remove(id);
      } else {
        _selectedDistortions.add(id);
      }
    });
  }

  Future<void> _submit() async {
    final situation = _situationController.text.trim();
    final autoThought = _automaticThoughtController.text.trim();
    final rationalResponse = _rationalResponseController.text.trim();

    if (situation.isEmpty) {
      _showError('Por favor, descreva a situação ou o que aconteceu.');
      setState(() => _currentStep = 0);
      return;
    }
    if (_selectedEmotions.isEmpty) {
      _showError('Selecione pelo menos uma emoção que você sentiu.');
      setState(() => _currentStep = 1);
      return;
    }
    if (autoThought.isEmpty) {
      _showError('Descreva o pensamento que passou pela sua cabeça.');
      setState(() => _currentStep = 2);
      return;
    }
    if (rationalResponse.isEmpty) {
      _showError('Escreva uma resposta racional ou um pensamento alternativo.');
      setState(() => _currentStep = 4);
      return;
    }

    setState(() => _saving = true);

    try {
      final List<EmotionIntensityItem> emotionsAfter = _selectedEmotions.map((e) {
        return EmotionIntensityItem(
          name: e.name,
          emoji: e.emoji,
          initialIntensity: e.initialIntensity,
          finalIntensity: _finalEmotionIntensities[e.name] ?? (e.initialIntensity * 0.4).round(),
        );
      }).toList();

      await _service.createThoughtRecord(
        situation: situation,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
        trigger: _triggerController.text.trim().isNotEmpty ? _triggerController.text.trim() : null,
        emotions: _selectedEmotions,
        automaticThought: autoThought,
        beliefInitial: _beliefInitial,
        cognitiveDistortions: _selectedDistortions,
        evidenceFor: _evidenceForController.text.trim().isNotEmpty ? _evidenceForController.text.trim() : null,
        evidenceAgainst: _evidenceAgainstController.text.trim().isNotEmpty ? _evidenceAgainstController.text.trim() : null,
        rationalResponse: rationalResponse,
        beliefFinal: _beliefFinal,
        emotionsAfter: emotionsAfter,
        behavior: _behaviorController.text.trim().isNotEmpty ? _behaviorController.text.trim() : null,
        tags: _selectedTags,
      );

      if (mounted) {
        setState(() {
          _saving = false;
          _showCelebration = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _showError('Erro ao salvar RPD: $e');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCelebration) {
      return _buildCelebrationScreen();
    }

    const totalSteps = 5;
    final progress = (_currentStep + 1) / totalSteps;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registro de Pensamentos (TCC)',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Auto-observação & Reestruturação Cognitiva',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de Progresso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Passo ${_currentStep + 1} de $totalSteps',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      Text(
                        _getStepTitle(_currentStep),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.patient),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.patient.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.patient),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo do Passo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: _buildCurrentStepContent(),
              ),
            ),

            // Barra Inferior de Navegação
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () => setState(() => _currentStep--),
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
                        onPressed: _saving
                            ? null
                            : () {
                                if (_currentStep < totalSteps - 1) {
                                  setState(() => _currentStep++);
                                } else {
                                  _submit();
                                }
                              },
                        child: _saving
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                _currentStep < totalSteps - 1 ? 'Continuar →' : 'Concluir Registro ✨',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return 'Situação & Gatilho';
      case 1: return 'Emoções Sentidas';
      case 2: return 'Pensamento Automático';
      case 3: return 'Armadilhas da Mente';
      case 4: return 'Resposta Racional';
      default: return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildStepSituation();
      case 1: return _buildStepEmotions();
      case 2: return _buildStepThoughts();
      case 3: return _buildStepDistortions();
      case 4: return _buildStepRationalResponse();
      default: return const SizedBox();
    }
  }

  // ── PASSO 1: SITUAÇÃO & GATILHO ─────────────────────────────────────────
  Widget _buildStepSituation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. O que estava acontecendo?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Descreva a situação real que disparou suas emoções. Onde você estava? Com quem? O que estava fazendo?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _situationController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ex: Estava no trabalho quando meu chefe me chamou para uma reunião inesperada...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Gatilho Específico (Opcional):',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _triggerController,
          decoration: InputDecoration(
            hintText: 'Ex: Mensagem no Slack, tom de voz, comentário...',
            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Área da Vida / Tags:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              selectedColor: AppColors.patient.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.patient : AppColors.textPrimary,
              ),
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── PASSO 2: EMOÇÕES SENTIDAS ───────────────────────────────────────────
  Widget _buildStepEmotions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. O que você sentiu no momento?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selecione uma ou mais emoções e regule a intensidade de 0% a 100%:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PrimaryEmotionsCatalog.all.map((e) {
            final name = e['name'] as String;
            final emoji = e['emoji'] as String;
            final isSelected = _selectedEmotions.any((item) => item.name == name);

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _toggleEmotion(e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.patient : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.patient : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        if (_selectedEmotions.isNotEmpty) ...[
          const Text(
            'Intensidade das Emoções Selecionadas:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ..._selectedEmotions.asMap().entries.map((entry) {
            final idx = entry.key;
            final emotion = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(emotion.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            emotion.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.patient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${emotion.initialIntensity}%',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: emotion.initialIntensity.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.patient,
                    onChanged: (val) {
                      setState(() {
                        _selectedEmotions[idx] = EmotionIntensityItem(
                          name: emotion.name,
                          emoji: emotion.emoji,
                          initialIntensity: val.round(),
                        );
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── PASSO 3: PENSAMENTOS AUTOMÁTICOS ────────────────────────────────────
  Widget _buildStepThoughts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. O que passou pela sua cabeça?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Qual foi o pensamento automático exato no momento da emoção? O que você interpretou sobre si mesmo, sobre os outros ou sobre o futuro?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _automaticThoughtController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Ex: "Ele vai me criticar e achar que meu trabalho é horrível. Não vou conseguir me defender."',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quanto você acreditou nisso?',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    '$_beliefInitial%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.patient),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Slider(
                value: _beliefInitial.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: AppColors.patient,
                onChanged: (v) => setState(() => _beliefInitial = v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('0% (Nem um pouco)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('100% (Certeza absoluta)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── PASSO 4: DISTORÇÕES COGNITIVAS ──────────────────────────────────────
  Widget _buildStepDistortions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Armadilhas do Pensamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Identifique se o seu pensamento caiu em alguma das distorções cognitivas clássicas da TCC:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 16),

        ...CognitiveDistortionCatalog.all.map((d) {
          final isSelected = _selectedDistortions.contains(d.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.patient.withValues(alpha: 0.08) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.patient : const Color(0xFFE2E8F0),
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Icon(d.icon, color: isSelected ? AppColors.patient : AppColors.textSecondary),
                title: Text(
                  d.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.patient : AppColors.textPrimary,
                  ),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  activeColor: AppColors.patient,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (_) => _toggleDistortion(d.id),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.description,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.35),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Exemplo: ${d.example}',
                            style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── PASSO 5: RESPOSTA RACIONAL & REESTRUTURAÇÃO ──────────────────────────
  Widget _buildStepRationalResponse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. Desafiando o Pensamento & Resposta Racional',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Examine as evidências e encontre uma perspectiva mais equilibrada e realista para a situação.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 16),

        // Evidências Contrárias
        const Text(
          'Evidências Contrárias (Que mostram que o pensamento pode não ser 100% verdade):',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _evidenceAgainstController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ex: Ele já elogiou minhas entregas anteriores; reuniões inesperadas acontecem sempre...',
            hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 16),

        // Resposta Racional
        const Text(
          'Pensamento Alternativo / Resposta Racional *:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.patient),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _rationalResponseController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ex: "Não tenho motivos para presumir o pior. Posso ouvir o que ele tem a dizer e resolver com calma."',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.patient, width: 1.5)),
          ),
        ),
        const SizedBox(height: 20),

        // Reavaliação da Crença no pensamento inicial
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reavaliação: Quanto você acredita no pensamento negativo agora?',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    '$_beliefFinal%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.success),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Slider(
                value: _beliefFinal.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: AppColors.success,
                onChanged: (v) => setState(() => _beliefFinal = v.round()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reavaliação das Emoções
        if (_selectedEmotions.isNotEmpty) ...[
          const Text(
            'Como estão suas emoções agora (Intensidade Final)?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ..._selectedEmotions.map((e) {
            final currentFinal = _finalEmotionIntensities[e.name] ?? (e.initialIntensity * 0.4).round();
            final relief = e.initialIntensity - currentFinal;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${e.emoji} ${e.name} (era ${e.initialIntensity}%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(
                        '$currentFinal% ${relief > 0 ? "(-$relief%) 🎉" : ""}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: relief > 0 ? AppColors.success : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: currentFinal.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.success,
                    onChanged: (val) {
                      setState(() {
                        _finalEmotionIntensities[e.name] = val.round();
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── TELA DE CELEBRAÇÃO ──────────────────────────────────────────────────
  Widget _buildCelebrationScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.patient, Color(0xFF38BDF8)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.patient.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.psychology_alt_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Excelente Reestruturação! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              const Text(
                'Você identificou seus pensamentos automáticos, desafiou as distorções cognitivas e encontrou uma perspectiva mais realista. Seu psicólogo terá acesso a essa evolução no painel clínico.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patient,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Voltar ao Meu Acompanhamento', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
