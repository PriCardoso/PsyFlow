# PsyFlow — Guia de Migração: Supabase → Firebase

## 1. Dependências (pubspec.yaml)

Remova:
```yaml
supabase_flutter: ...
```

Adicione:
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0
```

---

## 2. Inicialização (main.dart)

Substitua a inicialização do Supabase por:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // gerado pelo FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

Para gerar o `firebase_options.dart`:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 3. Estrutura do Firestore (equivalente às tabelas do Supabase)

| Supabase (tabela)               | Firestore (coleção)               | Chave de doc     |
|----------------------------------|-----------------------------------|------------------|
| `users`                         | `users/{uid}`                     | uid do Auth      |
| `mood_entries`                  | `mood_entries/{autoId}`           | auto             |
| `tasks`                         | `tasks/{autoId}`                  | auto             |
| `invites`                       | `invites/{autoId}`                | auto             |
| `links`                         | `links/{autoId}`                  | auto             |
| `appointments`                  | `appointments/{autoId}`           | auto             |
| `availability_slots`            | `availability_slots/{autoId}`     | auto             |
| `therapy_journeys`              | `therapy_journeys/{autoId}`       | auto             |
| `journey_steps`                 | `journey_steps/{autoId}`          | auto             |
| `patient_intervention_progress` | `patient_intervention_progress/{autoId}` | auto    |
| `emotional_logs`                | `emotional_logs/{autoId}`         | auto             |
| `intervention_templates`        | `intervention_templates/{autoId}` | auto             |
| `ai_recommendations`            | `ai_recommendations/{autoId}`     | auto             |
| `password_reset_codes`          | `password_reset_codes/{autoId}`   | auto             |

---

## 4. Regras de Segurança do Firestore (firestore.rules)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Usuários só leem/editam o próprio perfil
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid;
    }

    // mood_entries — paciente lê/escreve os próprios; psicólogo lê de pacientes vinculados
    match /mood_entries/{docId} {
      allow create: if request.auth.uid == request.resource.data.patient_id;
      allow read: if request.auth.uid == resource.data.patient_id
                  || isPsychologistOf(request.auth.uid, resource.data.patient_id);
    }

    // tasks — psicólogo escreve; paciente lê os próprios
    match /tasks/{docId} {
      allow read: if request.auth.uid == resource.data.patient_id
                  || request.auth.uid == resource.data.psychologist_id;
      allow create, update, delete: if request.auth.uid == resource.data.psychologist_id
                                    || request.auth.uid == request.resource.data.psychologist_id;
    }

    // invites — psicólogo cria os próprios
    match /invites/{docId} {
      allow create: if request.auth.uid == request.resource.data.psychologist_id;
      allow read: if request.auth != null;
      allow update: if request.auth != null; // paciente marca como usado
    }

    // links — lido por ambas as partes
    match /links/{docId} {
      allow read: if request.auth.uid == resource.data.psychologist_id
                  || request.auth.uid == resource.data.patient_id;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.psychologist_id;
    }

    // appointments
    match /appointments/{docId} {
      allow read: if request.auth.uid == resource.data.patient_id
                  || request.auth.uid == resource.data.psychologist_id;
      allow create: if request.auth != null;
    }

    // availability_slots — psicólogo gerencia os próprios
    match /availability_slots/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.psychologist_id
                   || request.auth.uid == request.resource.data.psychologist_id;
    }

    // Coleções de leitura pública autenticada
    match /intervention_templates/{docId} {
      allow read: if request.auth != null;
      allow write: if false; // só via console/admin
    }

    match /journey_steps/{docId} {
      allow read: if request.auth != null;
    }

    // Logs e progresso — paciente escreve/lê os próprios
    match /emotional_logs/{docId} {
      allow read, write: if request.auth.uid == resource.data.patient_id
                         || request.auth.uid == request.resource.data.patient_id;
    }

    match /patient_intervention_progress/{docId} {
      allow read, write: if request.auth != null;
    }

    match /ai_recommendations/{docId} {
      allow read, write: if request.auth != null;
    }

    match /password_reset_codes/{docId} {
      allow read, write: if request.auth != null;
    }

    // Helper: verifica se o psicólogo está vinculado ao paciente
    function isPsychologistOf(psychId, patientId) {
      return exists(/databases/$(database)/documents/links/$(psychId + '_' + patientId));
      // Adapte conforme o formato de ID que usar nos links
    }
  }
}
```

---

## 5. Índices do Firestore (firestore.indexes.json)

Crie no Firebase Console (ou no arquivo) os seguintes índices compostos:

```json
{
  "indexes": [
    {
      "collectionGroup": "mood_entries",
      "fields": [
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "tasks",
      "fields": [
        { "fieldPath": "psychologist_id", "order": "ASCENDING" },
        { "fieldPath": "due_date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "tasks",
      "fields": [
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "due_date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "tasks",
      "fields": [
        { "fieldPath": "psychologist_id", "order": "ASCENDING" },
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "due_date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "invites",
      "fields": [
        { "fieldPath": "psychologist_id", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "invites",
      "fields": [
        { "fieldPath": "code", "order": "ASCENDING" },
        { "fieldPath": "used", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "links",
      "fields": [
        { "fieldPath": "psychologist_id", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "links",
      "fields": [
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "active", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "availability_slots",
      "fields": [
        { "fieldPath": "psychologist_id", "order": "ASCENDING" },
        { "fieldPath": "is_active", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "emotional_logs",
      "fields": [
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "ai_recommendations",
      "fields": [
        { "fieldPath": "patient_id", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "password_reset_codes",
      "fields": [
        { "fieldPath": "email", "order": "ASCENDING" },
        { "fieldPath": "code", "order": "ASCENDING" },
        { "fieldPath": "used", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "journey_steps",
      "fields": [
        { "fieldPath": "protocol", "order": "ASCENDING" },
        { "fieldPath": "phase", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "intervention_templates",
      "fields": [
        { "fieldPath": "is_active", "order": "ASCENDING" },
        { "fieldPath": "category", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

## 6. AuthGate — adaptação para Firebase

Substitua os listeners do Supabase:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage(); // usuário logado
        }
        return const LoginPage(); // não autenticado
      },
    );
  }
}
```

---

## 7. Reset de Senha

O Firebase tem reset nativo por e-mail. Você pode:

**Opção A (recomendada):** usar `FirebaseAuth.instance.sendPasswordResetEmail(email: email)` e remover o fluxo de código customizado.

**Opção B (mantém código de 6 dígitos):** usar o `PasswordResetService` incluído nos arquivos, mas o envio do e-mail com o código precisa de uma **Cloud Function** (ver Firebase Functions).

---

## 8. RPC `generate_invite_code`

Essa função PostgreSQL não existe no Firebase. O `InviteService` migrado já gera o código diretamente no cliente com `Random.secure()` — sem necessidade de Cloud Function.

---

## 9. Checklist de migração

- [ ] Instalar FlutterFire CLI e rodar `flutterfire configure`
- [ ] Substituir dependências no `pubspec.yaml`
- [ ] Atualizar `main.dart` com `Firebase.initializeApp()`
- [ ] Substituir todos os services pelos arquivos gerados
- [ ] Atualizar `AuthGate` para `authStateChanges()`
- [ ] Atualizar todos os `import 'package:supabase_flutter/...'` nos widgets/pages
- [ ] Publicar regras de segurança no Firestore
- [ ] Criar índices compostos no Firebase Console
- [ ] Decidir fluxo de reset de senha (nativo vs customizado)
- [ ] Migrar dados existentes (se houver) via script de exportação do Supabase + importação no Firestore
