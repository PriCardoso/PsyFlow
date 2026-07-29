import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:psyflow_app/models/user_model.dart';
import 'package:psyflow_app/models/mood_model.dart';
import 'package:psyflow_app/models/task_item.dart';
import 'package:psyflow_app/models/clinical_session_model.dart';
import 'package:psyflow_app/models/clinical_scale_model.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  Future<Uint8List> generatePatientProgressReport({
    required String patientName,
    required String patientId,
    required String professionalName,
    required String professionalSpecialty,
    required List<MoodEntry> moodEntries,
    required List<TaskItem> tasks,
    required List<ClinicalSessionModel> sessions,
    required List<ClinicalScaleResponseModel> scaleResponses,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(
            patientName: patientName,
            professionalName: professionalName,
            professionalSpecialty: professionalSpecialty,
            periodStart: periodStart,
            periodEnd: periodEnd,
            font: font,
            fontBold: fontBold,
          ),
          pw.SizedBox(height: 24),
          _buildMoodSection(moodEntries, font, fontBold),
          pw.SizedBox(height: 16),
          _buildTaskAdherenceSection(tasks, font, fontBold),
          pw.SizedBox(height: 16),
          _buildSessionsSection(sessions, font, fontBold),
          pw.SizedBox(height: 16),
          _buildScalesSection(scaleResponses, font, fontBold),
          pw.SizedBox(height: 24),
          _buildFooter(font, fontBold),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader({
    required String patientName,
    required String professionalName,
    required String professionalSpecialty,
    required DateTime periodStart,
    required DateTime periodEnd,
    required pw.Font font,
    required pw.Font fontBold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PsyFlow',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 28,
                    color: PdfColor.fromHex('#2C5E7A'),
                  ),
                ),
                pw.Text(
                  'Relatório de Progresso Terapêutico',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 14,
                    color: PdfColor.fromHex('#666666'),
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#2C5E7A'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                'CONFIDENCIAL',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(thickness: 1, color: PdfColor.fromHex('#E0E0E0')),
        pw.SizedBox(height: 16),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildInfoRow(
                'Paciente',
                patientName,
                font,
                fontBold,
              ),
            ),
            pw.Expanded(
              child: _buildInfoRow(
                'Profissional',
                professionalName,
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildInfoRow(
                'Especialidade',
                professionalSpecialty,
                font,
                fontBold,
              ),
            ),
            pw.Expanded(
              child: _buildInfoRow(
                'Período',
                '${_formatDate(periodStart)} a ${_formatDate(periodEnd)}',
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildInfoRow(
                'Data do Relatório',
                _formatDate(DateTime.now()),
                font,
                fontBold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInfoRow(
    String label,
    String value,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
            color: PdfColor.fromHex('#999999'),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            color: PdfColor.fromHex('#333333'),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildMoodSection(
    List<MoodEntry> moodEntries,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (moodEntries.isEmpty) {
      return _buildEmptySection('Humor e Emoções', 'Nenhum registro de humor no período.', font, fontBold);
    }

    final avgMood = moodEntries.map((e) => e.mood).reduce((a, b) => a + b) / moodEntries.length;
    final moodCounts = <int, int>{};
    for (final entry in moodEntries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Humor e Emoções', fontBold),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildStatCard(
                'Média de Humor',
                avgMood.toStringAsFixed(1),
                '/ 5.0',
                PdfColor.fromHex('#4CAF50'),
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildStatCard(
                'Total de Registros',
                moodEntries.length.toString(),
                '',
                PdfColor.fromHex('#2C5E7A'),
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          'Distribuição de Humor:',
          style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromHex('#333333')),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [1, 2, 3, 4, 5].map((mood) {
            final count = moodCounts[mood] ?? 0;
            final percentage = moodEntries.isEmpty ? 0.0 : (count / moodEntries.length * 100);
            return pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    _getMoodLabel(mood),
                    style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromHex('#666666')),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    height: 40,
                    width: 20,
                    decoration: pw.BoxDecoration(
                      color: _getMoodColor(mood),
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Align(
                      alignment: pw.Alignment.bottomCenter,
                      child: pw.Container(
                        height: 40 * percentage / 100,
                        width: 20,
                        decoration: pw.BoxDecoration(
                          color: _getMoodColor(mood).withAlpha(200),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '$count (${percentage.toStringAsFixed(0)}%)',
                    style: pw.TextStyle(font: font, fontSize: 9, color: PdfColor.fromHex('#333333')),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  pw.Widget _buildStatCard(
    String title,
    String value,
    String suffix,
    PdfColor color,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColor.fromHex('#666666')),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: value,
                  style: pw.TextStyle(font: fontBold, fontSize: 20, color: color),
                ),
                pw.TextSpan(
                  text: suffix,
                  style: pw.TextStyle(font: font, fontSize: 12, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTaskAdherenceSection(
    List<TaskItem> tasks,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (tasks.isEmpty) {
      return _buildEmptySection('Tarefas Terapêuticas', 'Nenhuma tarefa atribuída no período.', font, fontBold);
    }

    final completed = tasks.where((t) => t.status == 'completed').length;
    final pending = tasks.where((t) => t.status == 'pending').length;
    final overdue = tasks.where((t) => t.status == 'overdue').length;
    final total = tasks.length;
    final adherence = total > 0 ? (completed / total * 100) : 0.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tarefas Terapêuticas', fontBold),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: _buildStatCard(
                'Aderência',
                adherence.toStringAsFixed(0),
                '%',
                adherence >= 70 ? PdfColor.fromHex('#4CAF50') : PdfColor.fromHex('#FF9800'),
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildStatCard(
                'Concluídas',
                completed.toString(),
                'de $total',
                PdfColor.fromHex('#4CAF50'),
                font,
                fontBold,
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: _buildStatCard(
                'Pendentes',
                '$pending / $overdue',
                'pend/atr.',
                PdfColor.fromHex('#FF9800'),
                font,
                fontBold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
            3: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('Tarefa', fontBold, isHeader: true),
                _buildTableCell('Categoria', fontBold, isHeader: true),
                _buildTableCell('Status', fontBold, isHeader: true),
                _buildTableCell('Data', fontBold, isHeader: true),
              ],
            ),
            ...tasks.take(15).map((task) => pw.TableRow(
              children: [
                _buildTableCell(task.title, font),
                _buildTableCell(task.category ?? '-', font),
                _buildTableCell(
                  _getTaskStatusLabel(task.status),
                  font,
                  color: _getTaskStatusColor(task.status),
                ),
                _buildTableCell(
                  task.dueDate != null ? _formatDate(task.dueDate!) : '-',
                  font,
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSessionsSection(
    List<ClinicalSessionModel> sessions,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (sessions.isEmpty) {
      return _buildEmptySection('Sessões Clínicas', 'Nenhuma sessão realizada no período.', font, fontBold);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sessões Clínicas', fontBold),
        pw.SizedBox(height: 8),
        pw.Text(
          'Total de sessões: ${sessions.length}',
          style: pw.TextStyle(font: font, fontSize: 11, color: PdfColor.fromHex('#666666')),
        ),
        pw.SizedBox(height: 12),
        ...sessions.take(10).map((session) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FAFAFA'),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0')),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _formatDate(session.sessionDate),
                    style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColor.fromHex('#333333')),
                  ),
                  pw.Text(
                    session.goalsAddressed.isNotEmpty
                        ? '${session.goalsAddressed.length} metas'
                        : '',
                    style: pw.TextStyle(font: font, fontSize: 10, color: PdfColor.fromHex('#999999')),
                  ),
                ],
              ),
              if (session.summary.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  session.summary,
                  style: pw.TextStyle(font: font, fontSize: 10, color: PdfColor.fromHex('#444444')),
                  maxLines: 3,
                  overflow: pw.TextOverflow.ellipsis,
                ),
              ],
              if (session.interventionsUsed.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: session.interventionsUsed.map((i) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#2C5E7A').withAlpha(30),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      i,
                      style: pw.TextStyle(font: font, fontSize: 8, color: PdfColor.fromHex('#2C5E7A')),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        )),
      ],
    );
  }

  pw.Widget _buildScalesSection(
    List<ClinicalScaleResponseModel> scaleResponses,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (scaleResponses.isEmpty) {
      return _buildEmptySection('Escalas Clínicas', 'Nenhuma escala aplicada no período.', font, fontBold);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Escalas Clínicas Aplicadas', fontBold),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColor.fromHex('#E0E0E0'), width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColor.fromHex('#F5F5F5')),
              children: [
                _buildTableCell('Escala', fontBold, isHeader: true),
                _buildTableCell('Pontuação', fontBold, isHeader: true),
                _buildTableCell('Interpretação', fontBold, isHeader: true),
                _buildTableCell('Data', fontBold, isHeader: true),
              ],
            ),
            ...scaleResponses.map((scale) => pw.TableRow(
              children: [
                _buildTableCell(scale.scaleCode, font),
                _buildTableCell(scale.totalScore.toString(), font),
                _buildTableCell(scale.severityInterpretation, font),
                _buildTableCell(_formatDate(scale.completedAt), font),
              ],
            )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildEmptySection(
    String title,
    String message,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, fontBold),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FAFAFA'),
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColor.fromHex('#E0E0E0'), style: pw.BorderStyle.dashed),
          ),
          child: pw.Text(
            message,
            style: pw.TextStyle(font: font, fontSize: 11, color: PdfColor.fromHex('#999999')),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromHex('#2C5E7A'), width: 2),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 14,
          color: PdfColor.fromHex('#2C5E7A'),
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isHeader ? font : font,
          fontSize: isHeader ? 10 : 9,
          color: color ?? (isHeader ? PdfColor.fromHex('#333333') : PdfColor.fromHex('#444444')),
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildFooter(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColor.fromHex('#E0E0E0')),
        pw.SizedBox(height: 12),
        pw.Text(
          'Este relatório é confidencial e destinado exclusivamente ao profissional de saúde responsável '
          'e ao paciente. A reprodução ou distribuição não autorizada é proibida.',
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
            color: PdfColor.fromHex('#999999'),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'PsyFlow - Plataforma Multidisciplinar de Cuidado em Saúde Mental',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 9,
            color: PdfColor.fromHex('#2C5E7A'),
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Muito Ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Neutro';
      case 4:
        return 'Bom';
      case 5:
        return 'Muito Bom';
      default:
        return '-';
    }
  }

  PdfColor _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return PdfColor.fromHex('#E53935');
      case 2:
        return PdfColor.fromHex('#FB8C00');
      case 3:
        return PdfColor.fromHex('#FDD835');
      case 4:
        return PdfColor.fromHex('#7CB342');
      case 5:
        return PdfColor.fromHex('#43A047');
      default:
        return PdfColor.fromHex('#999999');
    }
  }

  String _getTaskStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Concluída';
      case 'pending':
        return 'Pendente';
      case 'overdue':
        return 'Atrasada';
      case 'in_progress':
        return 'Em Andamento';
      default:
        return status;
    }
  }

  PdfColor _getTaskStatusColor(String status) {
    switch (status) {
      case 'completed':
        return PdfColor.fromHex('#4CAF50');
      case 'pending':
        return PdfColor.fromHex('#FF9800');
      case 'overdue':
        return PdfColor.fromHex('#F44336');
      case 'in_progress':
        return PdfColor.fromHex('#2196F3');
      default:
        return PdfColor.fromHex('#999999');
    }
  }

  Future<void> printReport(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  Future<void> shareReport(Uint8List pdfBytes, String fileName) async {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }
}