import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/therapist_patient_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../models/patient_link_model.dart';
import '../../../psychologist/patient_insights_dashboard_page.dart';
import '../../../psychologist/patient_profile_page.dart';

class LinkPatientPage extends StatefulWidget {
  const LinkPatientPage({super.key});

  @override
  State<LinkPatientPage> createState() => _LinkPatientPageState();
}

class _LinkPatientPageState extends State<LinkPatientPage> {
  final _service = sl<TherapistPatientService>();
  String? _generatedCode;
  bool _generating = false;
  bool _loading = true;
  List<TherapistPatientLink> _links = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final links = await _service.getMyPatientsLinks();
      if (mounted) {
        setState(() {
          _links = links;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generateCode() async {
    setState(() => _generating = true);
    try {
      final code = await _service.generateInviteCode();
      if (mounted) {
        setState(() {
          _generatedCode = code;
        });
        _loadData();
      }
    } catch (e) {
      if (mounted) _showError('Erro ao gerar código: $e');
    }
    if (mounted) setState(() => _generating = false);
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Código copiado para a área de transferência!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareWhatsApp(String code) {
    final message = 'Olá! Aqui está o seu código para se vincular a mim no app PsyFlow: *$code*\n\n'
        'Ao entrar no app, você já poderá preencher a ficha de avaliação inicial e registrar seu humor e sono para prepararmos nossa primeira consulta! 🧠🌱';
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share_rounded, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Mensagem para WhatsApp copiada com sucesso!')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vincular Paciente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.psychologist))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card de Geração do Código ──────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 44),
                        const SizedBox(height: 12),
                        const Text(
                          'Gerar Código de Vínculo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Gere o código de 6 dígitos para o paciente informar no app antes da primeira consulta. Válido por 7 dias.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_generatedCode != null) ...[
                          GestureDetector(
                            onTap: () => _copyCode(_generatedCode!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _generatedCode!,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF4F46E5),
                                      letterSpacing: 6,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.copy_rounded, color: Color(0xFF4F46E5), size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _shareWhatsApp(_generatedCode!),
                            icon: const Icon(Icons.share_rounded, size: 16),
                            label: const Text(
                              'Copiar mensagem para WhatsApp',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _generating ? null : _generateCode,
                            child: _generating
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Color(0xFF4F46E5), strokeWidth: 2.5),
                                  )
                                : Text(
                                    _generatedCode == null ? '+ Vincular novo paciente' : 'Gerar outro código',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Meus Pacientes Vinculados ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Meus Pacientes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_links.length} ativos',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_links.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 44, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum paciente vinculado',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gere um código acima e envie ao paciente para iniciar o acompanhamento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._links.map((link) => _buildPatientCard(link)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientCard(TherapistPatientLink link) {
    final name = link.patientProfile?.fullName ?? 'Paciente';
    final initials = link.patientProfile?.initials ?? 'P';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Acompanhamento ativo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                tooltip: 'Perfil Completo',
                onPressed: () {
                  if (link.patientProfile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientProfilePage(
                          link: PatientLink(
                            linkId: link.id,
                            active: link.isActive,
                            createdAt: link.createdAt,
                            patient: link.patientProfile!,
                          ),
                          onStatusChanged: _loadData,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Métricas resumidas no Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickMetric('Humor', link.avgMood != null ? link.avgMood!.toStringAsFixed(1) : '-', const Color(0xFF0EA5E9)),
                Container(width: 1, height: 24, color: Colors.black.withValues(alpha: 0.08)),
                _buildQuickMetric('Ansiedade', link.avgAnxiety != null ? link.avgAnxiety!.toStringAsFixed(1) : '-', const Color(0xFFF59E0B)),
                Container(width: 1, height: 24, color: Colors.black.withValues(alpha: 0.08)),
                _buildQuickMetric('Tarefas', link.totalTasks > 0 ? '${link.completedTasks}/${link.totalTasks}' : '0', const Color(0xFF10B981)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Botão Ver Acompanhamento
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                if (link.patientId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientInsightsDashboardPage(
                        patientId: link.patientId!,
                        patientName: name,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.insights_rounded, size: 18),
              label: const Text('Ver acompanhamento', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
