import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'NETWORK_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class PermissionException extends AppException {
  const PermissionException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'PERMISSION_DENIED',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class NotFoundException extends AppException {
  const NotFoundException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'NOT_FOUND',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class ValidationException extends AppException {
  const ValidationException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'VALIDATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class AuthException extends AppException {
  const AuthException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'AUTH_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class CacheException extends AppException {
  const CacheException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'CACHE_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class UnknownException extends AppException {
  const UnknownException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'UNKNOWN_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

AppException mapToAppException(dynamic error, [StackTrace? stackTrace]) {
  if (error is AppException) return error;
  if (error is FirebaseAuthException) {
    return _mapFirebaseAuthException(error, stackTrace);
  }
  if (error is FirebaseException) {
    return _mapFirebaseException(error, stackTrace);
  }
  if (error is FormatException || error is ArgumentError) {
    return ValidationException(
      error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  if (error is SocketException) {
    return NetworkException(
      'Sem conexão com a internet',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  return UnknownException(
    error.toString(),
    originalError: error,
    stackTrace: stackTrace,
  );
}

AppException _mapFirebaseAuthException(FirebaseAuthException e, StackTrace? stackTrace) {
  switch (e.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return AuthException('E-mail ou senha inválidos', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'email-already-in-use':
      return AuthException('Este e-mail já está cadastrado', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'weak-password':
      return ValidationException('A senha deve ter pelo menos 6 caracteres', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'invalid-email':
      return ValidationException('E-mail inválido', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'user-disabled':
      return AuthException('Esta conta foi desativada', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'too-many-requests':
      return NetworkException('Muitas tentativas. Tente novamente mais tarde', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'operation-not-allowed':
      return AuthException('Operação não permitida', code: e.code, originalError: e, stackTrace: stackTrace);
    default:
      return AuthException(e.message ?? 'Erro de autenticação', code: e.code, originalError: e, stackTrace: stackTrace);
  }
}

AppException _mapFirebaseException(FirebaseException e, StackTrace? stackTrace) {
  switch (e.code) {
    case 'permission-denied':
      return PermissionException('Sem permissão para esta operação', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'not-found':
      return NotFoundException('Documento não encontrado', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'already-exists':
      return ValidationException('Registro já existe', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'unavailable':
      return NetworkException('Serviço indisponível. Tente novamente', code: e.code, originalError: e, stackTrace: stackTrace);
    case 'deadline-exceeded':
      return NetworkException('Tempo limite excedido', code: e.code, originalError: e, stackTrace: stackTrace);
    default:
      return UnknownException(e.message ?? 'Erro do Firebase', code: e.code, originalError: e, stackTrace: stackTrace);
  }
}