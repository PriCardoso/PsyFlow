library;

import 'package:flutter/material.dart';

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
  const NetworkException(super.message, {super.originalError})
      : super(code: 'NETWORK_ERROR');
}

/// Permission denied errors
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message, {super.originalError})
      : super(code: 'PERMISSION_DENIED');
}

/// Not found errors
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.originalError})
      : super(code: 'NOT_FOUND');
}

/// Validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    super.originalError,
    this.fieldErrors,
  }) : super(code: 'VALIDATION_ERROR');
}

/// Authentication errors
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.originalError})
      : super(code: 'AUTH_ERROR');
}

/// Session expired
class SessionExpiredException extends AuthenticationException {
  const SessionExpiredException({super.originalError})
      : super('Sessão expirada. Faça login novamente.');
}

/// Firestore-specific errors
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.originalError})
      : super(code: 'FIRESTORE_ERROR');
}

/// Timeout errors
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.originalError})
      : super(code: 'TIMEOUT');
}

/// Unknown/generic errors
class UnknownException extends AppException {
  const UnknownException(super.message, {super.originalError})
      : super(code: 'UNKNOWN_ERROR');
}

/// Error handler utility
class ErrorHandler {
  /// Convert any error to AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    if (error is FormatException) {
      return const ValidationException('Formato de dados inválido');
    }

    if (error is ArgumentError) {
      return ValidationException(error.message?.toString() ?? 'Argumento inválido');
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}