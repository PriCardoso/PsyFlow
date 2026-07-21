# Melhorias Futuras - PsyFlow

Baseado na análise do projeto (analysis.md) e migração Supabase → Firebase concluída.

---

## 🎯 Prioridade Alta (P1-P2)

### 1. Testes Automatizados
- [ ] **Testes unitários** para services (`AuthService`, `UserService`, `TaskService`, `InviteService`, `MoodService`, `AppointmentService`)
- [ ] **Testes de widget** para páginas críticas (Login, Register, Dashboards, Agendamento)
- [ ] **Testes de integração** fluxo completo: convite → paciente → tarefa → humor
- [ ] Configurar CI/CD (GitHub Actions) para rodar testes em PR

### 2. Gerenciamento de Estado Global (Provider/Riverpod)
- [ ] Migrar `StatefulWidget` locais para `ChangeNotifier`/`Provider`
- [ ] Estado compartilhado: `UserProfile`, `Appointments`, `Tasks`, `Patients`
- [ ] Eliminar re-fetches desnecessários ao navegar entre páginas
- [ ] Implementar `Consumer`/`Selector` para rebuilds granulares

### 3. Tratamento de Erros Robusto
- [ ] Criar `AppException` hierarchy (NetworkError, PermissionDenied, NotFound, ValidationError)
- [ ] `ErrorHandler` centralizado com `SnackBar`/`Dialog` padronizados
- [ ] Retry automático com exponential backoff para operações de rede
- [ ] Offline-first: cache local (Hive/SharedPreferences) + sync quando online

### 4. Internacionalização (i18n)
- [ ] Extrair todas as strings hardcoded para `arb` files
- [ ] Configurar `intl` package + `flutter_localizations`
- [ ] Suporte inicial: Português (BR) + Inglês
- [ ] Seletor de idioma no perfil/configurações

### 5. Arquitetura - Repository Pattern
- [ ] Criar `lib/repositories/` com interfaces abstratas
- [ ] `UserRepository`, `TaskRepository`, `AppointmentRepository`, etc.
- [ ] Implementações `FirestoreUserRepository`, etc.
- [ ] Injeção de dependência via `get_it` ou `provider`

---

## 🎯 Prioridade Média (P3)

### 6. UI/UX - Design System Completo
- [ ] **Tipografia**: `textTheme` no `AppTheme` (headline, body, label, etc.)
- [ ] **Componentes base**: `AppButton`, `AppTextField`, `AppCard`, `AppDialog`, `AppSnackBar`
- [ ] **Tokens de design**: spacing, border-radius, elevation, shadows
- [ ] **Dark mode** completo (já usa Material3)

### 7. Performance - Queries Otimizadas
- [ ] Eliminar N+1 queries (ex: `InviteService.getMyPatients()` usa batch/stream)
- [ ] `StreamBuilder`/`Stream` para dados em tempo real (appointments, tasks, humor)
- [ ] Paginação (`limit` + `startAfter`) em listas longas
- [ ] Índices compostos já criados no `firestore.indexes.json`

### 8. Notificações Push
- [ ] `firebase_messaging` já configurado
- [ ] Tópicos: `patient_{uid}`, `psychologist_{uid}`
- [ ] Triggers: nova tarefa, lembrete humor, consulta agendada, convite
- [ ] Notificações locais (flutter_local_notifications) para offline

### 9. Analytics & Monitoramento
- [ ] `firebase_analytics` eventos customizados (login, task_complete, mood_log, appointment_book)
- [ ] `firebase_crashlytics` já configurado
- [ ] Dashboard de métricas: retenção, engajamento, funil de conversão

### 10. Acessibilidade (a11y)
- [ ] Semântica correta em botões, inputs, cards
- [ ] Contraste de cores (WCAG AA)
- [ ] Tamanhos de fonte escaláveis
- [ ] Suporte a TalkBack/VoiceOver

---

## 🎯 Prioridade Baixa (Nice to Have)

### 11. Funcionalidades Avançadas
- [ ] **Chat seguro** paciente ↔ psicólogo (Firestore + Crypto)
- [ ] **Relatórios PDF** de progresso (pdf package)
- [ ] **Exportação de dados** (LGPD/GDPR compliance)
- [ ] **Modo offline completo** com sync em background

### 12. DevOps & Qualidade
- [ ] `very_good_analysis` / `flutter_lints` strict
- [ ] Pre-commit hooks (husky + dart format + analyze)
- [ ] Feature flags (Firebase Remote Config)
- [ ] A/B testing para onboarding/flows

### 13. Documentação
- [ ] `README.md` completo (setup, arquitetura, deploy)
- [ ] `CONTRIBUTING.md`
- [ ] ADRs (Architecture Decision Records)
- [ ] Documentação de API (Firestore schema)

---

## 📋 Plano de Execução Sugerido

| Sprint | Foco | Entregáveis |
|--------|------|-------------|
| 1 | **Testes + Estado** | Unit tests (80% coverage), Provider setup, UserProvider |
| 2 | **Erros + i18n** | AppException, ErrorHandler, pt-BR/en-US |
| 3 | **Repository + UI** | Repository pattern, Design System v1 |
| 4 | **Performance + Push** | Streams, paginação, FCM topics |
| 5 | **Analytics + A11y** | Eventos GA, Crashlytics alerts, a11y audit |
| 6 | **Polish + Docs** | Dark mode, README, ADRs, release v1.0 |

---

## 🔧 Comandos Úteis

```bash
# Análise estática
flutter analyze

# Testes
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Build
flutter build apk --release
flutter build ios --release

# Deploy Firestore rules/indexes
firebase deploy --only firestore:rules,firestore:indexes

# Logs
flutter logs --device-id=<id>
```

Próximos Passos Pendentes (do melhorias.md)
- Repository Pattern (interfaces + implementações Firestore)
- i18n (intl + ARB files pt-BR/en-US)
- Testes unitários (80% coverage)
- CI/CD GitHub Actions
- Design System components
- Firebase Analytics eventos customizados
- Auditoria de acessibilidade