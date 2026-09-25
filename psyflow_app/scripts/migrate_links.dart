// ignore_for_file: avoid_print
/// Script de migração: `links` (legado) → `therapist_patient_links` (canônico)
///
/// Execução (no diretório raiz do projeto Flutter):
///   flutter run -d flutter-tester scripts/migrate_links.dart
///
/// OU execute via console do Firebase para ambientes de produção.
/// O script é idempotente: pode ser executado várias vezes sem duplicar dados.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:psyflow_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;

  print('🔄 Iniciando migração: links → therapist_patient_links');

  // 1. Ler todos os links ativos do sistema legado
  final legacySnap = await db
      .collection('links')
      .where('active', isEqualTo: true)
      .get();

  print('📋 Encontrados ${legacySnap.docs.length} vínculos ativos no sistema legado.');

  int migrated = 0;
  int skipped = 0;
  int errors = 0;

  for (final doc in legacySnap.docs) {
    final data = doc.data();
    final psychologistId = data['psychologist_id'] as String?;
    final patientId = data['patient_id'] as String?;

    if (psychologistId == null || patientId == null) {
      print('⚠️  Link ${doc.id} ignorado: sem psychologist_id ou patient_id');
      skipped++;
      continue;
    }

    try {
      // 2. O link ativo possui ID determinístico, o que também evita duplicatas.
      final target = db
          .collection('therapist_patient_links')
          .doc('${psychologistId}_$patientId');
      final existing = await target.get();

      if (existing.exists) {
        print('⏭️  Vínculo $psychologistId ↔ $patientId já existe. Ignorando.');
        skipped++;
        continue;
      }

      // 3. Buscar nomes desnormalizados
      String? patientName;
      String? therapistName;

      try {
        final patientDoc = await db.collection('users').doc(patientId).get();
        if (patientDoc.exists) {
          final d = patientDoc.data()!;
          patientName = (d['full_name'] ?? d['fullName'] ?? d['name']) as String?;
        }
      } catch (_) {}

      try {
        final therapistDoc = await db.collection('users').doc(psychologistId).get();
        if (therapistDoc.exists) {
          final d = therapistDoc.data()!;
          therapistName = (d['full_name'] ?? d['fullName'] ?? d['name']) as String?;
        }
      } catch (_) {}

      // 4. Criar em therapist_patient_links
      final createdAt = data['created_at'];
      await target.set({
        'psychologistId': psychologistId,
        'patientId': patientId,
        'inviteCode': '000000', // código legado desconhecido
        'status': 'active',
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3650))),
        'acceptedAt': createdAt ?? FieldValue.serverTimestamp(),
        'patientName': patientName,
        'therapistName': therapistName,
        'migratedFrom': 'links/${doc.id}',
      });

      print('✅ Migrado: $psychologistId ↔ $patientId (${patientName ?? "??"})');
      migrated++;
    } catch (e) {
      print('❌ Erro ao migrar ${doc.id}: $e');
      errors++;
    }
  }

  print('\n─────────────────────────────────────────');
  print('✅ Migrados  : $migrated');
  print('⏭️  Ignorados : $skipped');
  print('❌ Erros     : $errors');
  print('─────────────────────────────────────────');
  print('🏁 Migração concluída. Verifique os dados no console do Firebase.');
}
