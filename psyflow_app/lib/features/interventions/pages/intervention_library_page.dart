import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/intervention_service.dart';
import '../../../models/intervention_template.dart';

class InterventionLibraryPage extends StatefulWidget {
  const InterventionLibraryPage({super.key});

  @override
  State<InterventionLibraryPage> createState() => _InterventionLibraryPageState();
}

class _InterventionLibraryPageState extends State<InterventionLibraryPage> {
  final _service = InterventionService();
  List<InterventionTemplate> _all = [];
  List<InterventionTemplate> _filtered = [];
  String? _selectedCategory;
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getTemplates();
      if (mounted) {
        setState(() {
          _all = data;
          _filtered = data;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _applyFilter() {
    setState(() {
      _filtered = _all.where((t) {
        final matchCat = _selectedCategory == null || t.category == _selectedCategory;
        final matchSearch = _search.isEmpty ||
            t.title.toLowerCase().contains(_search.toLowerCase()) ||
            t.description.toLowerCase().contains(_search.toLowerCase());
        return matchCat && matchSearch;
      }).toList();
    });
  }

  List<String> get _categories {
    final cats = _all.map((t) => t.category).toSet().toList();
    cats.sort();
    return cats;
  }

  IconData _categoryIcon(String cat) {
    return switch (cat.toLowerCase()) {
      'tdah' => Icons.psychology_alt_rounded,
      'ansiedade' => Icons.self_improvement_rounded,
      'depressão' || 'depressao' => Icons.favorite_border_rounded,
      'tcc' => Icons.lightbulb_outline_rounded,
      'mindfulness' => Icons.spa_outlined,
      _ => Icons.task_alt_rounded,
    };
  }

  Color _difficultyColor(int level) {
    return switch (level) {
      1 => AppColors.cardGreen,
      2 => AppColors.cardOrange,
      _ => AppColors.error,
    };
  }

  String _difficultyLabel(int level) {
    return switch (level) {
      1 => 'Fácil',
      2 => 'Médio',
      _ => 'Avançado',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.psychologist,
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
                    colors: [AppColors.psychologist, AppColors.accentLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Biblioteca de Intervenções',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_all.length} intervenções disponíveis',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Busca e filtros
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) {
                      _search = v;
                      _applyFilter();
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar intervenção...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryChip(
                          label: 'Todas',
                          selected: _selectedCategory == null,
                          onTap: () {
                            _selectedCategory = null;
                            _applyFilter();
                          },
                        ),
                        ..._categories.map((cat) => _CategoryChip(
                              label: cat,
                              selected: _selectedCategory == cat,
                              onTap: () {
                                _selectedCategory = cat == _selectedCategory ? null : cat;
                                _applyFilter();
                              },
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.psychologist)),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 52, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const Text('Nenhuma intervenção encontrada', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _InterventionCard(
                    template: _filtered[i],
                    categoryIcon: _categoryIcon(_filtered[i].category),
                    difficultyColor: _difficultyColor(_filtered[i].difficultyLevel),
                    difficultyLabel: _difficultyLabel(_filtered[i].difficultyLevel),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.psychologist : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.psychologist : const Color(0xFFE0E7EF)),
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

class _InterventionCard extends StatelessWidget {
  final InterventionTemplate template;
  final IconData categoryIcon;
  final Color difficultyColor;
  final String difficultyLabel;

  const _InterventionCard({
    required this.template,
    required this.categoryIcon,
    required this.difficultyColor,
    required this.difficultyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECF1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.psychologist.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryIcon, color: AppColors.psychologist, size: 20),
          ),
          title: Text(
            template.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    difficultyLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: difficultyColor),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${template.estimatedMinutes} min • Fase ${template.phase}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFE7ECF1)),
                  const SizedBox(height: 8),
                  if (template.description.isNotEmpty) ...[
                    Text(template.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                    const SizedBox(height: 12),
                  ],
                  if (template.goal.isNotEmpty) ...[
                    _detail(Icons.flag_outlined, 'Objetivo', template.goal),
                    const SizedBox(height: 8),
                  ],
                  if (template.reflectionQuestion.isNotEmpty)
                    _detail(Icons.help_outline_rounded, 'Reflexão', template.reflectionQuestion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.psychologist),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.45),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
