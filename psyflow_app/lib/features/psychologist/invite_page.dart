import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/invite_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/patient_link_model.dart';
import 'patient_profile_page.dart';

class InvitePage extends StatefulWidget {
  const InvitePage({super.key});

  @override
  State<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends State<InvitePage> {
  final InviteService _inviteService = sl<InviteService>();

  String? generatedCode;

  bool generating = false;
  bool loadingData = true;

  List<Map<String, dynamic>> invites = [];
  List<PatientLink> patients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================================
  // CARREGAR DADOS
  // ==========================================================

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      loadingData = true;
    });

    try {
      final results = await Future.wait([
        _inviteService.getMyInvites(),
        _inviteService.getMyPatients(),
      ]);

      if (!mounted) return;

      setState(() {
        invites = results[0] as List<Map<String, dynamic>>;
        patients = results[1] as List<PatientLink>;
        loadingData = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados de vínculo: $e');

      if (!mounted) return;

      setState(() {
        loadingData = false;
      });

      _showError(
        'Não foi possível carregar os dados de vínculo.',
      );
    }
  }

  // ==========================================================
  // GERAR CÓDIGO
  // ==========================================================

  Future<void> _generateCode() async {
    if (generating) return;

    setState(() {
      generating = true;
    });

    try {
      final code = await _inviteService.generateInvite();

      if (!mounted) return;

      setState(() {
        generatedCode = code;
      });

      await _loadData();
    } catch (e, stackTrace) {
      debugPrint('Erro ao gerar convite: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showError(
        _friendlyErrorMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          generating = false;
        });
      }
    }
  }

  // ==========================================================
  // MENSAGEM DE ERRO
  // ==========================================================

  String _friendlyErrorMessage(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('permission-denied')) {
      return 'O Firebase bloqueou a criação do convite. '
          'Verifique as regras do Firestore.';
    }

    if (message.contains('unauthenticated')) {
      return 'Sua sessão expirou. Faça login novamente.';
    }

    if (message.contains('network')) {
      return 'Não foi possível conectar ao Firebase.';
    }

    return 'Erro ao gerar código de vínculo.';
  }

  // ==========================================================
  // COPIAR CÓDIGO
  // ==========================================================

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(
      ClipboardData(text: code),
    );

    if (!mounted) return;

    _showSuccess(
      'Código copiado!',
      Icons.check_circle_rounded,
    );
  }

  // ==========================================================
  // COPIAR MENSAGEM WHATSAPP
  // ==========================================================

  Future<void> _copyWhatsAppMessage(String code) async {
    final message =
        'Olá! Aqui está o seu código para se vincular a mim '
        'no app PsyFlow:\n\n'
        '$code\n\n'
        'Ao entrar no PsyFlow, informe esse código na opção '
        '"Vincular psicólogo". '
        'Assim você poderá preencher sua ficha inicial e '
        'registrar seu humor antes da nossa primeira consulta. 🧠🌱';

    await Clipboard.setData(
      ClipboardData(text: message),
    );

    if (!mounted) return;

    _showSuccess(
      'Mensagem para WhatsApp copiada!',
      Icons.share_rounded,
    );
  }

  // ==========================================================
  // SNACKBAR SUCESSO
  // ==========================================================

  void _showSuccess(
    String message,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================================
  // SNACKBAR ERRO
  // ==========================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Vincular Paciente',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: loadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.psychologist,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ==================================================
                    // CARD DE GERAÇÃO
                    // ==================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF4F46E5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),

                        borderRadius: BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1)
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

                          const Icon(
                            Icons.link_rounded,
                            color: Colors.white,
                            size: 40,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Vínculo Pré-Consulta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Gere um código de 6 dígitos para que '
                            'seu paciente possa se vincular ao '
                            'seu perfil antes da primeira consulta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.9,
                              ),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // CÓDIGO
                          // ==========================================

                          if (generatedCode != null) ...[
                            GestureDetector(
                              onTap: () {
                                _copyCode(generatedCode!);
                              },

                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),

                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,

                                  children: [

                                    Text(
                                      generatedCode!,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight:
                                            FontWeight.w900,
                                        color:
                                            Color(0xFF4F46E5),
                                        letterSpacing: 6,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    const Icon(
                                      Icons.copy_rounded,
                                      color:
                                          Color(0xFF4F46E5),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Toque no código para copiar',
                              style: TextStyle(
                                color:
                                    Colors.white.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ========================================
                            // WHATSAPP
                            // ========================================

                            SizedBox(
                              width: double.infinity,

                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(
                                    alpha: 0.18,
                                  ),
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  _copyWhatsAppMessage(
                                    generatedCode!,
                                  );
                                },

                                icon: const Icon(
                                  Icons.send_to_mobile_rounded,
                                  size: 18,
                                ),

                                label: const Text(
                                  'Copiar mensagem para WhatsApp',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],

                          // ==========================================
                          // BOTÃO GERAR
                          // ==========================================

                          SizedBox(
                            width: double.infinity,
                            height: 52,

                            child: ElevatedButton(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white,
                                foregroundColor:
                                    const Color(0xFF4F46E5),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),
                                elevation: 0,
                              ),

                              onPressed: generating
                                  ? null
                                  : _generateCode,

                              child: generating
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            Color(0xFF4F46E5),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      generatedCode == null
                                          ? 'Gerar código'
                                          : 'Gerar novo código',
                                      style:
                                          const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // PACIENTES
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        const Text(
                          'Pacientes Vinculados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.success
                                .withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),

                          child: Text(
                            '${patients.length} vinculados',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // SEM PACIENTES
                    // ==================================================

                    if (patients.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.black
                                .withValues(alpha: 0.05),
                          ),
                        ),

                        child: Column(
                          children: [

                            Icon(
                              Icons.person_add_disabled_rounded,
                              size: 38,
                              color: Colors.grey.shade400,
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Nenhum paciente vinculado ainda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color:
                                    AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              'Gere um código e envie para '
                              'seu paciente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )

                    // ==================================================
                    // LISTA DE PACIENTES
                    // ==================================================

                    else
                      ListView.builder(
                        shrinkWrap: true,

                        physics:
                            const NeverScrollableScrollPhysics(),

                        itemCount: patients.length,

                        itemBuilder:
                            (context, index) {

                          final link =
                              patients[index];

                          return Container(
                            margin:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                              border: Border.all(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.05,
                                ),
                              ),
                            ),

                            child: ListTile(

                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),

                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color(0xFF6366F1)
                                        .withValues(
                                  alpha: 0.15,
                                ),

                                child: Text(
                                  link.patient.initials,
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(0xFF6366F1),
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),

                              title: Text(
                                link.patient.fullName,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),

                              subtitle: Row(
                                children: [

                                  Container(
                                    width: 7,
                                    height: 7,

                                    decoration:
                                        BoxDecoration(
                                      color: link.active
                                          ? AppColors.success
                                          : AppColors
                                              .textSecondary,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    link.active
                                        ? 'Vínculo Ativo'
                                        : 'Inativo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w600,
                                      color: link.active
                                          ? AppColors.success
                                          : AppColors
                                              .textSecondary,
                                    ),
                                  ),
                                ],
                              ),

                              trailing:
                                  const Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                                size: 14,
                                color:
                                    AppColors.textSecondary,
                              ),

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PatientProfilePage(
                                      link: link,
                                      onStatusChanged:
                                          _loadData,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}