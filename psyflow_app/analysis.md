# Análise do Projeto PsyFlow 🧠

## Visão Geral

**PsyFlow** é um app Flutter para intervenções terapêuticas, conectando psicólogos e pacientes. A estrutura base é razoável, mas há vários problemas críticos e oportunidades de melhoria importantes.

---

## 🔴 Problemas Críticos

### 1. Inconsistência de Backend — Firebase vs Supabase

Este é o problema mais grave do projeto. O código está **dividido entre dois backends incompatíveis**:

| Arquivo | Backend usado |
|---|---|
| `auth_service.dart` | Firebase Auth |
| `user_service.dart` | Firebase Firestore |
| `task_service.dart` | Firebase Firestore |
| `invite_service.dart` | Firebase Firestore |
| `mood_service.dart` | Firebase Firestore |
| `auth_gate.dart` | **Supabase** (`supabase_flutter`) |
| `patient_dashboard_page.dart` | **Supabase** (`Supabase.instance.client`) |
| `psychologist_dashboard_page.dart` | **Supabase** (`Supabase.instance.client`) |
| `appointment_service.dart` | **Supabase** (construtor recebe `SupabaseClient`) |

O app **nunca funcionará corretamente** nesse estado. `AuthGate` usa Supabase Auth para checar sessão, mas `AuthService` faz login via Firebase Auth — são sessions completamente separadas.

> [!CAUTION]
> O `pubspec.yaml` **não contém** `supabase_flutter` como dependência, mas vários arquivos importam esse pacote. O projeto provavelmente não compila.

---

### 2. `AppointmentService` com assinatura quebrada

O serviço foi refatorado para Firebase, mas os dashboards ainda passam `Supabase.instance.client` no construtor:

```dart
// Dashboard (ERRADO - passa SupabaseClient)
final _appointmentService = AppointmentService(Supabase.instance.client);

// AppointmentService (espera FirebaseFirestore agora)
class AppointmentService {
  final FirebaseFirestore _db;
  AppointmentService(this._db); // ← conflito de tipos
}
```

---

### 3. `other_services.dart` — `import` no meio do arquivo

```dart
// linha 93 — INVÁLIDO em Dart!
import '../../models/intervention_template.dart';
```
Em Dart, todos os `import` devem estar no topo do arquivo. Isso causa erro de compilação.

---

### 4. `UserModel` com campo de chave errado

O `UserService.saveProfile()` salva `full_name` no Firestore, mas `UserModel.fromMap()` lê `fullName`:

```dart
// UserService salva:
'full_name': fullName,

// UserModel lê:
fullName: map["fullName"] ?? "",  // ← chave diferente, sempre vazia!
```

---

### 5. `PasswordResetService` usa `Random()` em vez de `Random.secure()`

O código de reset de senha (6 dígitos) usa `Random()` não-criptográfico, o que é um risco de segurança:

```dart
final rnd = Random(); // ← vulnerável
final code = (100000 + rnd.nextInt(900000)).toString();
```

---

## 🟡 Problemas de Arquitetura

### 6. Repositório vazio

O diretório `lib/repositories/` existe mas está **completamente vazio**. A intenção era separar a camada de acesso a dados, mas toda a lógica de dados está espalhada em `lib/core/services/`. A arquitetura ficou incompleta.

### 7. Estado gerenciado diretamente nas páginas (sem gerenciamento de estado)

Apesar de `provider: ^6.1.5` estar no `pubspec.yaml`, **nenhuma Provider/ChangeNotifier** está sendo usada. Todo o estado (dados do usuário, appointments, loading) fica em `StatefulWidget` locais, causando:
- Re-fetches desnecessários ao navegar
- Dados não compartilhados entre páginas
- Dificuldade de teste

### 8. `other_services.dart` — arquivo "depósito"

Um único arquivo de 221 linhas contém 5 classes completamente não relacionadas: `JourneyService`, `ProgressService`, `EmotionalLogService`, `InterventionService`, `RecommendationService`. Devem ser arquivos separados.

### 9. Chamadas N+1 ao Firestore

Em `InviteService.getMyPatients()` e `TaskService.getTasksCreatedByMe()`, para cada item da lista é feita uma chamada individual ao Firestore:

```dart
// Para cada paciente, 1 chamada individual ao Firestore
final enriched = await Future.wait(links.map((link) async {
  final patientDoc = await _db.collection('users').doc(link['patient_id']).get();
  ...
}));
```

Com 20 pacientes = 21 reads. Isso não escala e aumenta custos.

### 10. `AppColors` incompleto — falta `patient` e `psychologist`

`auth_gate.dart` e os dashboards referenciam `AppColors.patient` e `AppColors.psychologist`, mas `app_theme.dart` só define 5 cores:

```dart
class AppColors {
  static const primary = Color(0xff3D6B7D);
  static const secondary = Color(0xffE5B96B);
  static const background = Color(0xffF7F7F5);
  static const surface = Colors.white;
  static const error = Colors.red;
  // ← faltam: patient, psychologist, ...
}
```

---

## 🟢 Oportunidades de Melhoria

### 11. `AppTheme` muito simples

O tema atual não define nada além do `scaffoldBackgroundColor` e `ColorScheme`. Falta definir tipografia (`textTheme`), estilo de botões, inputs, cards — tudo está sendo estilizado inline nas páginas.

### 12. Sem tratamento de erros de rede

Os erros são capturados mas apenas relançados como `Exception('Erro ao...: $e')`. Não há distinção entre "sem conexão" e "permission denied" do Firestore, por exemplo. Mensagens de erro genéricas chegam ao usuário.

### 13. Sem testes

O diretório `test/` existe mas está (presumivelmente) vazio. Nenhum serviço tem testes unitários.

### 14. Sem internacionalização (i18n)

Strings em português estão hardcoded por todo o app. Se o projeto crescer para outros idiomas, será um retrabalho enorme.

### 15. `description` do app ainda é o padrão

```yaml
# pubspec.yaml
description: "A new Flutter project."  # ← deve descrever o app real
```

---

## 📋 Resumo de Prioridades

| Prioridade | Problema | Impacto |
|---|---|---|
| 🔴 P0 | Conflito Firebase vs Supabase | App não funciona |
| 🔴 P0 | `import` no meio de arquivo | Não compila |
| 🔴 P0 | `AppointmentService` com tipo errado | Crash em runtime |
| 🔴 P1 | `UserModel` chave errada (`full_name` vs `fullName`) | Nome sempre vazio |
| 🟡 P1 | `AppColors` faltando constantes | Erro de compilação |
| 🟡 P2 | Repositório vazio / arquitetura incompleta | Manutenibilidade |
| 🟡 P2 | Sem estado global (Provider não usado) | Performance/DX |
| 🟡 P2 | Chamadas N+1 ao Firestore | Escala e custo |
| 🟢 P3 | `other_services.dart` monolítico | Organização |
| 🟢 P3 | Tema incompleto | UI inconsistente |
| 🟢 P3 | Sem testes | Qualidade |