import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/thought_record_model.dart';

class ThoughtRecordDetailsDialog extends StatelessWidget {
  final ThoughtRecordEntry record;
  final VoidCallback? onDelete;

  const ThoughtRecordDetailsDialog({
    super.key,
    required this.record,
    this.onDelete,
  });

  String _formatDate(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} de ${months[d.month - 1]} de ${d.year} às $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final relief = record.averageRelief;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.patient.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppColors.patient, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registro de Pensamento (RPD)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          _formatDate(record.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (relief > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '-$relief% Alívio 🎉',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.success),
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
            const Divider(height: 20),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Situação
                    _buildSectionHeader('1. Situação & Contexto', Icons.place_rounded),
                    _buildContentBox(record.situation),
                    if (record.trigger != null && record.trigger!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Gatilho: ${record.trigger}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 16),

                    // 2. Emoções Iniciais vs Finais
                    _buildSectionHeader('2. Emoções Sentidas', Icons.emoji_emotions_rounded),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: record.emotions.map((e) {
                        final eAfter = record.emotionsAfter.firstWhere(
                          (a) => a.name == e.name,
                          orElse: () => e,
                        );
                        final finalInt = eAfter.finalIntensity;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(e.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text('${e.name}: ', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                              Text('${e.initialIntensity}%', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                              if (finalInt != null) ...[
                                const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.textSecondary),
                                Text(
                                  '$finalInt%',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: finalInt < e.initialIntensity ? AppColors.success : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 3. Pensamentos Automáticos
                    _buildSectionHeader('3. Pensamento Automático', Icons.bolt_rounded),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"${record.automaticThought}"',
                            style: const TextStyle(fontSize: 13.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Crença inicial no pensamento: ${record.beliefInitial}% ${record.beliefFinal != null ? "➔ caiu para ${record.beliefFinal}%" : ""}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Distorções Cognitivas Identificadas
                    if (record.cognitiveDistortions.isNotEmpty) ...[
                      _buildSectionHeader('4. Distorções Cognitivas Identificadas', Icons.psychology_alt_rounded),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: record.cognitiveDistortions.map((id) {
                          final info = CognitiveDistortionCatalog.findById(id);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.patient.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(info?.icon ?? Icons.label_important_outline_rounded, size: 14, color: AppColors.patient),
                                const SizedBox(width: 5),
                                Text(
                                  info?.shortName ?? id,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.patient),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5. Resposta Racional / Reestruturação
                    _buildSectionHeader('5. Resposta Racional & Reestruturação', Icons.check_circle_outline_rounded),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        record.rationalResponse,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (record.evidenceAgainst != null && record.evidenceAgainst!.isNotEmpty) ...[
                      _buildSectionHeader('Evidências Contrárias', Icons.balance_rounded),
                      _buildContentBox(record.evidenceAgainst!),
                      const SizedBox(height: 16),
                    ],

                    if (record.tags.isNotEmpty) ...[
                      _buildSectionHeader('Áreas & Tags', Icons.tag_rounded),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: record.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                          child: Text('#$t', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.patient),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildContentBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35)),
    );
  }
}
