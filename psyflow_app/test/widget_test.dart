import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:psyflow_app/app/app.dart';
import 'package:psyflow_app/firebase_options.dart';

void main() {
  testWidgets('PsyFlowApp loads test', (WidgetTester tester) async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PsyFlowApp());
  });
}
