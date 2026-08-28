import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Wrapper sobre [FirebaseAnalytics] com eventos customizados do PsyFlow.
///
/// Todos os eventos são silenciosamente ignorados em caso de erro para
/// não impactar a experiência do usuário.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  // ── Autenticação ──────────────────────────────────────────────────────────

  /// Usuário fez login com [method] (ex: 'email', 'google').
  Future<void> logLogin({String method = 'email'}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('[Analytics] logLogin error: $e');
    }
  }

  /// Usuário se registrou com [method].
  Future<void> logSignUp({String method = 'email'}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('[Analytics] logSignUp error: $e');
    }
  }

  /// Usuário fez logout.
  Future<void> logLogout() async {
    try {
      await _analytics.logEvent(name: 'logout');
    } catch (e) {
      debugPrint('[Analytics] logLogout error: $e');
    }
  }

  // ── Usuário ───────────────────────────────────────────────────────────────

  /// Define o ID do usuário para atribuição de eventos.
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint('[Analytics] setUserId error: $e');
    }
  }

  /// Define propriedades do usuário (role: 'patient' | 'psychologist').
  Future<void> setUserRole(String role) async {
    try {
      await _analytics.setUserProperty(name: 'user_role', value: role);
    } catch (e) {
      debugPrint('[Analytics] setUserRole error: $e');
    }
  }

  // ── Tarefas ───────────────────────────────────────────────────────────────

  /// Psicólogo criou uma tarefa para [patientId].
  Future<void> logTaskCreated({String? patientId}) async {
    try {
      await _analytics.logEvent(
        name: 'task_created',
        parameters: {
          if (patientId != null) 'patient_id': patientId,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logTaskCreated error: $e');
    }
  }

  /// Paciente concluiu uma tarefa com [taskId].
  Future<void> logTaskCompleted({String? taskId}) async {
    try {
      await _analytics.logEvent(
        name: 'task_completed',
        parameters: {
          if (taskId != null) 'task_id': taskId,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logTaskCompleted error: $e');
    }
  }

  // ── Humor ─────────────────────────────────────────────────────────────────

  /// Paciente registrou humor com [moodScore] (1-10).
  Future<void> logMoodLogged({required int moodScore}) async {
    try {
      await _analytics.logEvent(
        name: 'mood_logged',
        parameters: {'mood_score': moodScore},
      );
    } catch (e) {
      debugPrint('[Analytics] logMoodLogged error: $e');
    }
  }

  // ── Agendamentos ──────────────────────────────────────────────────────────

  /// Paciente agendou uma consulta com [psychologistId].
  Future<void> logAppointmentBooked({String? psychologistId}) async {
    try {
      await _analytics.logEvent(
        name: 'appointment_booked',
        parameters: {
          if (psychologistId != null) 'psychologist_id': psychologistId,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logAppointmentBooked error: $e');
    }
  }

  /// Consulta foi cancelada.
  Future<void> logAppointmentCancelled({String? appointmentId}) async {
    try {
      await _analytics.logEvent(
        name: 'appointment_cancelled',
        parameters: {
          if (appointmentId != null) 'appointment_id': appointmentId,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logAppointmentCancelled error: $e');
    }
  }

  // ── Convites ──────────────────────────────────────────────────────────────

  /// Psicólogo gerou um código de convite.
  Future<void> logInviteGenerated() async {
    try {
      await _analytics.logEvent(name: 'invite_generated');
    } catch (e) {
      debugPrint('[Analytics] logInviteGenerated error: $e');
    }
  }

  /// Paciente usou um código de convite com sucesso.
  Future<void> logInviteUsed() async {
    try {
      await _analytics.logEvent(name: 'invite_used');
    } catch (e) {
      debugPrint('[Analytics] logInviteUsed error: $e');
    }
  }

  // ── Protocolos & Escalas ──────────────────────────────────────────────────

  /// Paciente iniciou um protocolo.
  Future<void> logProtocolStarted({String? protocolId}) async {
    try {
      await _analytics.logEvent(
        name: 'protocol_started',
        parameters: {
          if (protocolId != null) 'protocol_id': protocolId,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logProtocolStarted error: $e');
    }
  }

  /// Paciente respondeu uma escala clínica.
  Future<void> logScaleCompleted({String? scaleName}) async {
    try {
      await _analytics.logEvent(
        name: 'scale_completed',
        parameters: {
          if (scaleName != null) 'scale_name': scaleName,
        },
      );
    } catch (e) {
      debugPrint('[Analytics] logScaleCompleted error: $e');
    }
  }

  // ── Telas ─────────────────────────────────────────────────────────────────

  /// Registra visualização de tela (alternativa ao automático do Firebase).
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      debugPrint('[Analytics] logScreenView error: $e');
    }
  }
}
