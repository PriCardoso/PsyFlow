import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_template.dart';
import '../../models/task_template_model.dart';

class EspacoPsyFlowPage extends StatefulWidget {
  final String? initialCategory;

  const EspacoPsyFlowPage({super.key, this.initialCategory});

  @override
  State<EspacoPsyFlowPage> createState() => _EspacoPsyFlowPageState();
}

class _EspacoPsyFlowPageState extends State<EspacoPsyFlowPage> {
  String? _selectedCategory;
  String _searchQuery = '';
  Set<String> _completedTemplateIds = {};
  bool _loading = true;

  final Map<String, _CategoryMeta> _categoriesMeta = {
    TaskTemplates.catFoco: const _CategoryMeta(
      label: 'Foco & TDAH',
      icon: Icons.track_changes_rounded,
      color: Color(0xFF6366F1),
      gradient: [Color(0xFF6366F1), Color(0xFF818CF8)],
      description: 'Estratégias práticas para vencer distrações e gerenciar o foco diário.',
    ),
    TaskTemplates.catAnsiedade: const _CategoryMeta(
      label: 'Ansiedade & Calma',
      icon: Icons.spa_rounded,
      color: Color(0xFF0EA5E9),
      gradient: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
      description: 'Técnicas de desaceleração, aterramento sensorial e regulação emocional.',
    ),
    TaskTemplates.catTcc: const _CategoryMeta(
      label: 'TCC & Pensamentos',
      icon: Icons.psychology_rounded,
      color: Color(0xFF8B5CF6),
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      description: 'Reestruturação cognitiva, identificação de pensamentos automáticos e crenças.',
    ),
    TaskTemplates.catDepressao: const _CategoryMeta(
      label: 'Ativação & Humor',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFF59E0B),
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      description: 'Ativação comportamental, metas pequenas e autocuidado para elevar a energia.',
    ),
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('patient_intervention_progress')
          .where('patient_id', isEqualTo: user.uid)
          .get();

      final completedIds = snap.docs
          .map((d) => d.data()['template_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      if (mounted) {
        setState(() {
          _completedTemplateIds = completedIds;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TaskTemplate> get _filteredTemplates {
    return TaskTemplates.all.where((t) {
      final matchCat = _selectedCategory == null || t.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.protocol.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  void _openActivity(TaskTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ActivityExecutionSheet(
        template: template,
        meta: _categoriesMeta[template.category] ?? _defaultMeta,
        isCompleted: _completedTemplateIds.contains(template.id),
        onCompleted: () {
          _loadProgress();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Parabéns! Atividade "${template.title}" concluída com sucesso!'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  _CategoryMeta get _defaultMeta => const _CategoryMeta(
        label: 'Geral',
        icon: Icons.star_rounded,
        color: AppColors.patient,
        gradient: [AppColors.patient, AppColors.accentLight],
        description: 'Atividades terapêuticas guiadas.',
      );

  @override
  Widget build(BuildContext context) {
    final templates = _filteredTemplates;
    final totalAvailable = TaskTemplates.all.length;
    final totalCompleted = _completedTemplateIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header Premium ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
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
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('💜 Espaço Terapêutico', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Espaço PsyFlow',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exercícios práticos e ferramentas guiadas para o seu bem-estar diário',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Progresso do Paciente ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$totalCompleted de $totalAvailable atividades concluídas',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: totalAvailable > 0 ? (totalCompleted / totalAvailable) : 0,
                              backgroundColor: const Color(0xFFEAEFF5),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Seletor de Temas ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temas e Habilidades',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Todos
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('✨ Todos os temas'),
                            selected: _selectedCategory == null,
                            selectedColor: const Color(0xFF6366F1),
                            labelStyle: TextStyle(
                              color: _selectedCategory == null ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            onSelected: (_) => setState(() => _selectedCategory = null),
                          ),
                        ),
                        // Categorias
                        ..._categoriesMeta.entries.map((entry) {
                          final isSelected = _selectedCategory == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(entry.value.icon, size: 16, color: isSelected ? Colors.white : entry.value.color),
                              label: Text(entry.value.label),
                              selected: isSelected,
                              selectedColor: entry.value.color,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              onSelected: (_) => setState(() => _selectedCategory = entry.key),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Barra de busca ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar exercício por palavra-chave...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ),

          // ── Lista de Atividades ────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
            )
          else if (templates.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    const Text(
                      'Nenhuma atividade encontrada',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tente mudar os filtros ou a busca',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _selectedCategory = null;
                        _searchQuery = '';
                      }),
                      child: const Text('Limpar filtros'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final template = templates[index];
                    final meta = _categoriesMeta[template.category] ?? _defaultMeta;
                    final isCompleted = _completedTemplateIds.contains(template.id);

                    return _ActivityCard(
                      template: template,
                      meta: meta,
                      isCompleted: isCompleted,
                      onTap: () => _openActivity(template),
                    );
                  },
                  childCount: templates.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryMeta {
  final String label;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String description;

  const _CategoryMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.description,
  });
}

class _ActivityCard extends StatelessWidget {
  final TaskTemplate template;
  final _CategoryMeta meta;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.template,
    required this.meta,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyText = template.difficultyLevel == 1
        ? 'Iniciante'
        : template.difficultyLevel == 2
            ? 'Intermediário'
            : 'Desafiador';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? AppColors.success.withValues(alpha: 0.35) : const Color(0xFFE8EEF5),
          width: isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: meta.gradient),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(meta.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              template.protocol,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: meta.color,
                              ),
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                            Text(
                              difficultyText,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Feita',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                template.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    isCompleted ? 'Praticar novamente' : 'Iniciar exercício',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? AppColors.success : meta.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: isCompleted ? AppColors.success : meta.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Modal de Execução Interativa da Atividade ─────────────────────

class _ActivityExecutionSheet extends StatefulWidget {
  final TaskTemplate template;
  final _CategoryMeta meta;
  final bool isCompleted;
  final VoidCallback onCompleted;

  const _ActivityExecutionSheet({
    required this.template,
    required this.meta,
    required this.isCompleted,
    required this.onCompleted,
  });

  @override
  State<_ActivityExecutionSheet> createState() => _ActivityExecutionSheetState();
}

class _ActivityExecutionSheetState extends State<_ActivityExecutionSheet> {
  final _notesController = TextEditingController();
  int _moodBefore = 3;
  int _moodAfter = 4;
  bool _saving = false;

  final List<String> _moodEmojis = ['😢', '😕', '😐', '🙂', '😄'];
  final List<String> _moodLabels = ['Muito mal', 'Mal', 'Neutro', 'Bem', 'Muito bem'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _completeActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('patient_intervention_progress').add({
        'patient_id': user.uid,
        'template_id': widget.template.id,
        'title': widget.template.title,
        'category': widget.template.category,
        'protocol': widget.template.protocol,
        'reflection_question': widget.template.reflectionQuestion,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'mood_before': _moodBefore,
        'mood_after': _moodAfter,
        'completed_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onCompleted();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar progresso: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Barra de arrasto
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.meta.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.template.categoryLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.meta.color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Conteúdo do exercício
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    Text(
                      widget.template.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.psychology_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Protocolo: ${widget.template.protocol}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Caixa de Instruções Passo a Passo
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_walk_rounded, color: widget.meta.color, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Como praticar esta atividade:',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.template.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Humor antes da prática
                    const Text(
                      '1. Como você está se sentindo agora (antes de começar)?',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (i) {
                        final val = i + 1;
                        final isSel = _moodBefore == val;
                        return GestureDetector(
                          onTap: () => setState(() => _moodBefore = val),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? widget.meta.color.withValues(alpha: 0.15) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? widget.meta.color : const Color(0xFFE2E8F0),
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(_moodEmojis[i], style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  _moodLabels[i],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                    color: isSel ? widget.meta.color : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Pergunta de reflexão interativa
                    if (widget.template.reflectionQuestion != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.edit_note_rounded, color: AppColors.patient, size: 22),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '2. Para refletir e registrar:',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.template.reflectionQuestion!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Escreva suas observações, aprendizados ou percepções...',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Humor após a prática
                    const Text(
                      '3. Como você está se sentindo após o exercício?',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (i) {
                        final val = i + 1;
                        final isSel = _moodAfter == val;
                        return GestureDetector(
                          onTap: () => setState(() => _moodAfter = val),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.success.withValues(alpha: 0.15) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppColors.success : const Color(0xFFE2E8F0),
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(_moodEmojis[i], style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  _moodLabels[i],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                    color: isSel ? AppColors.success : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Botão Concluir
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _saving ? null : _completeActivity,
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.task_alt_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Concluir Atividade no Espaço',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
