import 'dart:async';

typedef AsyncAction<T> = Future<T> Function();

/// Retry an async [action] up to [retries] times with exponential backoff.
/// [delayFactor] is multiplied each attempt (in milliseconds).
Future<T> retry<T>(
  AsyncAction<T> action, {
  int retries = 3,
  Duration initialDelay = const Duration(milliseconds: 300),
  double delayFactor = 2.0,
  bool Function(Exception)? retryIf,
}) async {
  var attempt = 0;
  var delay = initialDelay;
  while (true) {
    try {
      return await action();
    } catch (e) {
      attempt += 1;
      if (attempt > retries || e is! Exception) rethrow;
      if (retryIf != null && !retryIf(e)) rethrow;
      await Future.delayed(delay);
      delay = Duration(milliseconds: (delay.inMilliseconds * delayFactor).toInt());
    }
  }
}
