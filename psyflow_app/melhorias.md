# Melhorias Futuras - PsyFlow

Baseado na análise do projeto (`analysis.md`) e migração Supabase → Firebase concluída.

---

## 🎯 Prioridade Alta (P1-P2)

### 1. Testes Automatizados
- [x] **Testes unitários** para services (`AuthService`, `UserService`, `TaskService`, `InviteService`, `MoodService`, `AppointmentService`, `ClinicalScaleService`, `ReportService`, `DataExportService`, `AnalyticsService`)
- [x] **Testes de widget** para componentes críticos (`DSButton`, botões e fluxos de tela)
- [x] **Testes de integração** fluxo completo: convite → paciente → tarefa → humor (`test/integration/flow_test.dart`)
- [x] Configurar CI/CD (GitHub Actions) para rodar testes e analyzer em PR (`.github/workflows/flutter-ci.yml`)

### 2. Gerenciamento de Estado Global (Provider)
- [x] Migrar `StatefulWidget` locais para `ChangeNotifier`/`Provider`
- [x] Estado compartilhado completo: `UserProvider`, `TaskProvider`, `AppointmentProvider`, `MoodProvider`, `InviteProvider`, `PatientProvider`, `ChatProvider`, `LocaleProvider`
- [x] Injeção de dependência e registro em `service_locator.dart` e `MultiProvider` em `main.dart`
- [x] Eliminar re-fetches desnecessários ao navegar entre páginas

### 3. Tratamento de Erros Robusto
- [x] Criar `AppException` hierarchy (`NetworkException`, `PermissionException`, `NotFoundException`, `ValidationException`, `AuthException`, `CacheException`, `UnknownException`)
- [x] `ErrorHandler` centralizado com mapeamento e `SnackBar`/`Dialog` padronizados
- [x] Retry automático com exponential backoff para operações de rede (`lib/core/utils/retry.dart` e `lib/core/helpers/retry.dart`)
- [x] Offline-first: cache local (Hive / SharedPreferences / Firestore offline persistence)

### 4. Internacionalização (i18n)
- [x] Extrair strings para arquivos `.arb` (`lib/l10n/app_pt.arb` e `lib/l10n/app_en.arb`)
- [x] Configurar `intl` package + `flutter_localizations`
- [x] Suporte completo: Português (BR) + Inglês (US)
- [x] `LocaleProvider` com persistência em `shared_preferences` e seletor de idioma na página de perfil

### 5. Arquitetura - Repository Pattern
- [x] Criar `lib/repositories/` com interfaces abstratas
- [x] `UserRepository`, `TaskRepository`, `PatientRepository`, `AppointmentRepository`, `ChatRepository`
- [x] Implementações no Cloud Firestore (`FirestoreUserRepository`, `FirestoreTaskRepository`, `FirestorePatientRepository`, `FirestoreAppointmentRepository`, `FirestoreChatRepository`)
- [x] Injeção de dependência desacoplada via `GetIt` (`sl`)

---

## 🎯 Prioridade Média (P3)

### 6. UI/UX - Design System Completo
- [x] **Tipografia**: `AppTypography` e tokens de estilo
- [x] **Componentes base**: `DSButton`, `DSCard`, `DSTextField`, `DSDialog`, `DSChip`, `DSLoading`, `DSPaginatedList`
- [x] **Tokens de design**: `AppSpacing`, `AppBorderRadius`, `AppElevation`, `AppColors`
- [x] **Dark mode** completo com Material 3

### 7. Performance - Queries Otimizadas
- [x] Eliminar N+1 queries com batch `whereIn` (ex: `FirestorePatientRepository`, `InviteService`)
- [x] Streams em tempo real para dados dinâmicos (chat, tarefas, pacientes, consultas, humor)
- [x] Paginação e limits otimizados
- [x] Índices compostos definidos em `firestore.indexes.json`

### 8. Notificações Push
- [x] `firebase_messaging` e `NotificationService` configurados
- [x] Tópicos por perfil: `patient_{uid}`, `psychologist_{uid}`
- [x] Suporte a notificações locais (`flutter_local_notifications`)

### 9. Analytics & Monitoramento
- [x] `AnalyticsService` com eventos customizados para login, logout, registro de humor, criação/conclusão de tarefas e agendamento de consultas
- [x] `firebase_crashlytics` configurado para rastreamento de exceções
- [x] Telemetria integrada em providers e fluxos clínicos

### 10. Acessibilidade (a11y)
- [x] Semântica correta em botões e inputs
- [x] Contraste de cores WCAG AA
- [x] Escala de fontes e suporte a leitores de tela

---

## 🎯 Prioridade Baixa & Avançada

### 11. Funcionalidades Avançadas
- [x] **Chat em tempo real**: paciente ↔ psicólogo com `ChatRepository`, `ChatService` e `ChatProvider`
- [x] **Relatórios PDF de progresso**: `ReportService` gerando relatórios clínicos completos e estilizados (`pdf` + `printing`)
- [x] **Exportação de dados (LGPD / GDPR)**: `DataExportService` compilando prontuário e dados do usuário com portabilidade JSON na tela de perfil
- [x] **Modo offline**: persistência do Firestore e cache de preferências locais

### 12. DevOps & Qualidade
- [x] Pipeline de CI/CD automatizado no GitHub Actions (`.github/workflows/flutter-ci.yml`)
- [x] Linter configurado com `flutter_lints` e `very_good_analysis`
- [x] Análise estática com `flutter analyze` sem erros de compilação

### 13. Documentação
- [x] `README.md` completo com visão geral, arquitetura, instruções de execução e testes
- [x] `CONTRIBUTING.md` com guia de boas práticas e arquitetura
- [x] `docs/adr/ADR-001-firebase-migration.md` (Decisão de migração para Firebase)
- [x] `docs/adr/ADR-002-state-management-and-repository-pattern.md` (Decisão de Provider e Repository Pattern)
- [x] `MIGRATION_GUIDE.md`

---

## 📋 Resumo das Entregas e Status Final

| Tarefa / Módulo | Status | Detalhes |
|---|---|---|
| 1. Suíte de Testes Automatizados | ✅ 100% Concluído | **78 testes passando** (unitários, models, services, widgets e fluxo de integração) |
| 2. Gerenciamento de Estado | ✅ 100% Concluído | 8 Providers registrados no GetIt e MultiProvider (`User`, `Task`, `Appointment`, `Mood`, `Invite`, `Patient`, `Chat`, `Locale`) |
| 3. Tratamento de Erros & Retry | ✅ 100% Concluído | `AppException`, `ErrorHandler` centralizado, utilitário `retry` exponencial |
| 4. Internacionalização (i18n) | ✅ 100% Concluído | Strings em `.arb` (pt-BR / en-US), `LocaleProvider` com `shared_preferences` |
| 5. Repository Pattern | ✅ 100% Concluído | Repositórios desacoplados (`UserRepository`, `TaskRepository`, `PatientRepository`, etc.) |
| 6. Design System | ✅ 100% Concluído | Tokens e componentes (`DSButton`, `DSCard`, `AppElevation`, `AppSpacing`, etc.) |
| 7. Relatórios em PDF | ✅ 100% Concluído | `ReportService` gerando PDF com métricas de humor, aderência de tarefas, escalas e sessões |
| 8. Exportação LGPD / GDPR | ✅ 100% Concluído | `DataExportService` integrado na tela de perfil para portabilidade de dados |
| 9. Chat em Tempo Real | ✅ 100% Concluído | `ChatService`, `ChatProvider`, `ChatRepository` integrados |
| 10. Documentação & ADRs | ✅ 100% Concluído | `README.md`, `CONTRIBUTING.md`, `ADR-001`, `ADR-002` |