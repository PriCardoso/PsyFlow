import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app_exception.dart';

class ErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error, [
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  ]) {
    final appException = mapToAppException(error, stackTrace);
    _logError(appException);
    _showErrorDialog(context, appException, onRetry);
  }

  static void handleErrorSilent(dynamic error, [StackTrace? stackTrace]) {
    final appException = mapToAppException(error, stackTrace);
    _logError(appException);
  }

  static void _logError(AppException exception) {
    if (kDebugMode) {
      debugPrint('🔴 ${exception.runtimeType}: ${exception.message}');
      if (exception.originalError != null) {
        debugPrint('   Original: ${exception.originalError}');
      }
      if (exception.stackTrace != null) {
        debugPrint('   Stack: ${exception.stackTrace}');
      }
    }
  }

  static void _showErrorDialog(
    BuildContext context,
    AppException exception,
    VoidCallback? onRetry,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIcon(exception), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(exception.message)),
          ],
        ),
        backgroundColor: _getColor(exception),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Tentar novamente',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static IconData _getIcon(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return Icons.wifi_off_rounded;
      case PermissionException:
        return Icons.lock_outline_rounded;
      case NotFoundException:
        return Icons.search_off_rounded;
      case ValidationException:
        return Icons.error_outline_rounded;
      case AuthException:
        return Icons.person_off_rounded;
      case CacheException:
        return Icons.storage_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  static Color _getColor(AppException exception) {
    switch (exception.runtimeType) {
      case ValidationException:
        return Colors.orange.shade700;
      case NetworkException:
        return Colors.red.shade700;
      default:
        return Colors.red.shade700;
    }
  }
}

extension ErrorHandling on Future {
  Future<T> handleError<T>(
    BuildContext context, [
    VoidCallback? onRetry,
  ]) async {
    try {
      return await this as Future<T>;
    } catch (e, stackTrace) {
      ErrorHandler.handleError(context, e, stackTrace, onRetry);
      rethrow;
    }
  }

  Future<T?> handleErrorSilent<T>() async {
    try {
      return await this as Future<T>;
    } catch (e, stackTrace) {
      ErrorHandler.handleErrorSilent(e, stackTrace);
      return null;
    }
  }
}