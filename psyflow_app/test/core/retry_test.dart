import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

import 'package:psyflow_app/core/utils/retry.dart';

void main() {
  test('retry succeeds after transient failures', () async {
    var calls = 0;
    final result = await retry<int>(() async {
      calls++;
      if (calls < 3) throw Exception('transient');
      return 42;
    }, retries: 5, initialDelay: Duration(milliseconds: 1));

    expect(result, 42);
    expect(calls, 3);
  });

  test('retry rethrows when non-Exception thrown', () async {
    await expectLater(
      retry(() async => throw Error()),
      throwsA(isA<Error>()),
    );
  });
}
