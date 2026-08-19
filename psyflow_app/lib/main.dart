import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/service_locator.dart';
import 'core/providers/providers.dart';
import 'firebase_options.dart';
import 'l10n/generated/app_localizations.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<UserProvider>()),
        ChangeNotifierProvider(create: (_) => sl<TaskProvider>()),
        ChangeNotifierProvider(create: (_) => sl<AppointmentProvider>()),
        ChangeNotifierProvider(create: (_) => sl<MoodProvider>()),
        ChangeNotifierProvider(create: (_) => sl<InviteProvider>()),
      ],
      child: const PsyFlowApp(),
    ),
  );
}