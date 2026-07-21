/// Base exception class for the app
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network connectivity errors
class NetworkException extends AppException {
  const NetworkException(String message, {super.originalError})
      : super(message, code: 'NETWORK_ERROR');
}

/// Permission denied errors
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(String message, {super.originalError})
      : super(message, code: 'PERMISSION_DENIED');
}

/// Not found errors
class NotFoundException extends AppException {
  const NotFoundException(String message, {super.originalError})
      : super(message, code: 'NOT_FOUND');
}

/// Validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    String message, {
    super.originalError,
    this.fieldErrors,
  }) : super(message, code: 'VALIDATION_ERROR');
}

/// Authentication errors
class AuthenticationException extends AppException {
  const AuthenticationException(String message, {super.originalError})
      : super(message, code: 'AUTH_ERROR');
}

/// Session expired
class SessionExpiredException extends AuthenticationException {
  const SessionExpiredException({super.originalError})
      : super('Sessão expirada. Faça login novamente.');
}

/// Firestore-specific errors
class FirestoreException extends AppException {
  const FirestoreException(String message, {super.originalError})
      : super(message, code: 'FIRESTORE_ERROR');
}

/// Timeout errors
class TimeoutException extends AppException {
  const TimeoutException(String message, {super.originalError})
      : super(message, code: 'TIMEOUT');
}

/// Unknown/generic errors
class UnknownException extends AppException {
  const UnknownException(String message, {super.originalError})
      : super(message, code: 'UNKNOWN_ERROR');
}

/// Error handler utility
class ErrorHandler {
  /// Convert any error to AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    if (error is FormatException) {
      return const ValidationException('Formato de dados inválido');
    }

    if (error is ArgumentError) {
      return ValidationException(error.message);
    }

    if (error is StateError) {
      return UnknownException('Erro de estado: ${error.message}');
    }

    // Generic fallback
    return UnknownException(
      error.toString(),
      originalError: error,
    );
  }

  static AppException _handleFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return PermissionDeniedException(
          'Sem permissão para realizar esta operação',
          originalError: e,
        );
      case 'not-found':
        return NotFoundException(
          'Recurso não encontrado',
          originalError: e,
        );
      case 'unavailable':
        return NetworkException(
          'Serviço indisponível. Verifique sua conexão.',
          originalError: e,
        );
      case 'deadline-exceeded':
        return TimeoutException(
          'Operação excedeu o tempo limite',
          originalError: e,
        );
      case 'unauthenticated':
        return SessionExpiredException(originalError: e);
      case 'already-exists':
        return ValidationException(
          'Este recurso já existe',
          originalError: e,
        );
      case 'failed-precondition':
        return ValidationException(
          'Pré-condição falhou: ${e.message}',
          originalError: e,
        );
      case 'aborted':
        return UnknownException(
          'Operação cancelada devido a conflito',
          originalError: e,
        );
      case 'out-of-range':
        return ValidationException(
          'Valor fora do intervalo permitido',
          originalError: e,
        );
      case 'unimplemented':
        return UnknownException(
          'Funcionalidade não implementada',
          originalError: e,
        );
      case 'internal':
        return FirestoreException(
          'Erro interno do servidor',
          originalError: e,
        );
      case 'data-loss':
        return FirestoreException(
          'Perda de dados detectada',
          originalError: e,
        );
      default:
        return UnknownException(
          'Erro do Firebase: ${e.message}',
          originalError: e,
        );
    }
  }

  /// Get user-friendly message
  static String getUserMessage(AppException e) {
    switch (e.code) {
      case 'NETWORK_ERROR':
        return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
      case 'PERMISSION_DENIED':
        return 'Você não tem permissão para esta ação.';
      case 'NOT_FOUND':
        return 'O recurso solicitado não foi encontrado.';
      case 'VALIDATION_ERROR':
        return e.message;
      case 'AUTH_ERROR':
      case 'SESSION_EXPIRED':
        return 'Sua sessão expirou. Por favor, faça login novamente.';
      case 'FIRESTORE_ERROR':
        return 'Erro ao acessar o banco de dados. Tente novamente.';
      case 'TIMEOUT':
        return 'A operação demorou muito. Verifique sua conexão e tente novamente.';
      case 'UNKNOWN_ERROR':
      default:
        return 'Ocorreu um erro inesperado. Tente novamente ou contate o suporte.';
    }
  }

  /// Show error in SnackBar
  static void showSnackBar(BuildContext context, AppException e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getUserMessage(e)),
        backgroundColor: _getColorForError(e),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: e.code == 'SESSION_EXPIRED'
            ? SnackBarAction(
                label: 'Login',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to login - implement based on your navigation
                },
              )
            : null,
      ),
    );
  }

  /// Show error in Dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    AppException e, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? 'Erro'),
        content: Text(getUserMessage(e)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onRetry();
              },
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }

  static Color _getColorForError(AppException e) {
    switch (e.code) {
      case 'NETWORK_ERROR':
      case 'TIMEOUT':
        return Colors.orange;
      case 'PERMISSION_DENIED':
      case 'AUTH_ERROR':
      case 'SESSION_EXPIRED':
        return Colors.red;
      case 'VALIDATION_ERROR':
        return Colors.blue;
      default:
        return Colors.red;
    }
  }
}

/// FirebaseException import helper (avoid circular imports)
class FirebaseException implements Exception {
  final String code;
  final String message;
  final String? plugin;
  final StackTrace? stackTrace;

  const FirebaseException({
    required this.code,
    required this.message,
    this.plugin,
    this.stackTrace,
  });

  @override
  String toString() => 'FirebaseException: $code - $message';
}