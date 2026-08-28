import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mood_model.dart';

class ClinicalReportGeneratorDialog extends StatefulWidget {
  final String patientId;
  final String patientName;
  final List<MoodEntry> entries;
  final int completedTasks;
  final int totalTasks;

  const ClinicalReportGeneratorDialog({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.entries,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  State<ClinicalReportGeneratorDialog> createState() => _ClinicalReportGeneratorDialogState();
}

class _ClinicalReportGeneratorDialogState extends State<ClinicalReportGeneratorDialog> {
  bool _includeMood = true;
  bool _includeAnxiety = true;
  bool _includeSleep = true;
  bool _includeEnergy = true;
  bool _includeTasks = true;
  bool _includeNotes = true;
  bool _includeClinicalObservations = true;

  final _psychologistNotesController = TextEditingController();
  bool _previewMode = false;

  @override
  void dispose() {
    _psychologistNotesController.dispose();
    super.dispose();
  }

  String _generateReportText() {
    final now = DateTime.now();
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final dateFormatted = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    // Cálculo das médias dos registros
    double avgMood = 0;
    double avgAnxiety = 0;
    double avgSleep = 0;
    double avgEnergy = 0;
    double avgStress = 0;

    if (widget.entries.isNotEmpty) {
      avgMood = widget.entries.map((e) => e.mood).reduce((a, b) => a + b) / widget.entries.length;
      avgAnxiety = widget.entries.map((e) => e.anxiety).reduce((a, b) => a + b) / widget.entries.length;
      avgSleep = widget.entries.map((e) => e.sleepQuality).reduce((a, b) => a + b) / widget.entries.length;
      avgEnergy = widget.entries.map((e) => e.energy).reduce((a, b) => a + b) / widget.entries.length;
      avgStress = widget.entries.map((e) => e.stress).reduce((a, b) => a + b) / widget.entries.length;
    }

    final buffer = StringBuffer();
    buffer.writeln('=====================================================');
    buffer.writeln('           RELATÓRIO DE ACOMPANHAMENTO CLÍNICO       ');
    buffer.writeln('                     PsyFlow Insights                ');
    buffer.writeln('=====================================================');
    buffer.writeln('Paciente: ${widget.patientName}');
    buffer.writeln('Data de emissão: $dateFormatted');
    buffer.writeln('Total de registros no período: ${widget.entries.length}');
    buffer.writeln('-----------------------------------------------------');
    buffer.writeln('');

    buffer.writeln('1. RESUMO DOS INDICADORES (Escala 1 a 10)');
    if (_includeMood) {
      buffer.writeln('   • Humor médio .................... ${avgMood > 0 ? avgMood.toStringAsFixed(1) : 'N/A'}/10');
    }
    if (_includeAnxiety) {
      buffer.writeln('   • Ansiedade média ................ ${avgAnxiety > 0 ? avgAnxiety.toStringAsFixed(1) : 'N/A'}/10');
    }
    if (_includeSleep) {
      buffer.writeln('   • Qualidade de sono média ........ ${avgSleep > 0 ? avgSleep.toStringAsFixed(1) : 'N/A'}/10');
    }
    if (_includeEnergy) {
      buffer.writeln('   • Nível de energia médio ......... ${avgEnergy > 0 ? avgEnergy.toStringAsFixed(1) : 'N/A'}/10');
      buffer.writeln('   • Estresse médio ................. ${avgStress > 0 ? avgStress.toStringAsFixed(1) : 'N/A'}/10');
    }
    buffer.writeln('');

    if (_includeTasks) {
      buffer.writeln('2. ADESÃO ÀS TAREFAS TERAPÊUTICAS');
      buffer.writeln('   • Tarefas atribuídas ............. ${widget.totalTasks}');
      buffer.writeln('   • Tarefas concluídas ............. ${widget.completedTasks}');
      final rate = widget.totalTasks > 0
          ? (widget.completedTasks / widget.totalTasks * 100).toStringAsFixed(1)
          : '0.0';
      buffer.writeln('   • Taxa de adesão ................. $rate%');
      buffer.writeln('');
    }

    if (_includeClinicalObservations) {
      buffer.writeln('3. PADRÕES E CORRELAÇÕES OBSERVADAS');
      final highAnxiety = widget.entries.where((e) => e.anxiety >= 8).length;
      final poorSleep = widget.entries.where((e) => e.sleepQuality <= 4).length;

      if (highAnxiety > 0) {
        buffer.writeln('   • Registrados $highAnxiety picos de ansiedade elevada (≥ 8) no período.');
      }
      if (poorSleep > 0) {
        buffer.writeln('   • Registradas $poorSleep noites com sono insatisfatório (≤ 4).');
      }

      // Fatores de maior frequência
      final factorCount = <String, int>{};
      for (final e in widget.entries) {
        for (final f in e.factors) {
          factorCount[f] = (factorCount[f] ?? 0) + 1;
        }
      }
      if (factorCount.isNotEmpty) {
        final top = factorCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final topStr = top.take(3).map((e) => '${e.key} (${e.value}x)').join(', ');
        buffer.writeln('   • Fatores de influência mais citados: $topStr');
      }
      buffer.writeln('');
    }

    if (_includeNotes) {
      final entriesWithNotes = widget.entries.where((e) => e.notes != null && e.notes!.trim().isNotEmpty).toList();
      if (entriesWithNotes.isNotEmpty) {
        buffer.writeln('4. EXCERTOS DO DIÁRIO / NOTAS DO PACIENTE');
        for (final entry in entriesWithNotes.take(5)) {
          final d = entry.createdAt;
          final dStr = '${d.day.toString().padLeft(2, '0')}/${months[d.month - 1]}';
          buffer.writeln('   • [$dStr] "${entry.notes!.trim()}"');
        }
        buffer.writeln('');
      }
    }

    if (_psychologistNotesController.text.trim().isNotEmpty) {
      buffer.writeln('5. OBSERVAÇÕES E CONDUTA DO PSICÓLOGO');
      buffer.writeln('   ${_psychologistNotesController.text.trim()}');
      buffer.writeln('');
    }

    buffer.writeln('-----------------------------------------------------');
    buffer.writeln('Relatório gerado automaticamente através do PsyFlow.');
    buffer.writeln('Documento confidencial destinado a suporte do processo terapêutico.');

    return buffer.toString();
  }

  void _copyToClipboard() {
    final text = _generateReportText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('Relatório copiado para a área de transferência!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 680),
        child: Column(
          children: [
            // Header do Modal
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.psychologist,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gerar Relatório Clínico',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Acompanhamento longitudinal do paciente',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Toggle Configurar / Pré-visualizar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: !_previewMode,
                      label: const Center(child: Text('⚙️ Configurar Itens')),
                      labelStyle: TextStyle(
                        fontWeight: !_previewMode ? FontWeight.w800 : FontWeight.w500,
                        color: !_previewMode ? AppColors.psychologist : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.psychologist.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (v) => setState(() => _previewMode = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      selected: _previewMode,
                      label: const Center(child: Text('📄 Pré-visualizar')),
                      labelStyle: TextStyle(
                        fontWeight: _previewMode ? FontWeight.w800 : FontWeight.w500,
                        color: _previewMode ? AppColors.psychologist : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.psychologist.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (v) => setState(() => _previewMode = true),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Corpo
            Expanded(
              child: _previewMode ? _buildPreviewView() : _buildConfigurationView(),
            ),

            // Rodapé de Ações
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
              ),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copiar Texto', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.psychologist,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _copyToClipboard();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Concluir & Copiar', style: TextStyle(fontWeight: FontWeight.w800)),
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

  Widget _buildConfigurationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione as seções que farão parte do relatório:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _buildCheckboxTile('Evolução do Humor', 'Média de humor de 1 a 10', _includeMood, (v) => setState(() => _includeMood = v!)),
          _buildCheckboxTile('Ansiedade & Agitação', 'Níveis médios e picos registrados', _includeAnxiety, (v) => setState(() => _includeAnxiety = v!)),
          _buildCheckboxTile('Qualidade do Sono', 'Média de noites reparadoras', _includeSleep, (v) => setState(() => _includeSleep = v!)),
          _buildCheckboxTile('Energia & Estresse', 'Métricas de vitalidade e tensão', _includeEnergy, (v) => setState(() => _includeEnergy = v!)),
          _buildCheckboxTile('Adesão às Tarefas', 'Quantidade e taxa de tarefas concluídas', _includeTasks, (v) => setState(() => _includeTasks = v!)),
          _buildCheckboxTile('Padrões & Correlações', 'Cruzamentos e fatores mais citados', _includeClinicalObservations, (v) => setState(() => _includeClinicalObservations = v!)),
          _buildCheckboxTile('Excertos do Diário', 'Notas e reflexões escritas pelo paciente', _includeNotes, (v) => setState(() => _includeNotes = v!)),
          const SizedBox(height: 16),
          const Text(
            'Observações do Psicólogo (Opcional):',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _psychologistNotesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Adicione anotações de evolução clínica, metas ou recomendações...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    final reportText = _generateReportText();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          reportText,
          style: const TextStyle(
            color: Color(0xFFF1F5F9),
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String title, String subtitle, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      value: value,
      activeColor: AppColors.psychologist,
      onChanged: onChanged,
    );
  }
}
