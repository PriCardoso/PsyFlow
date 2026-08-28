# ADR 002: Gerenciamento de Estado com Provider e Repository Pattern

## Status
Aceito

## Contexto
O aplicativo precisava de desacoplamento entre camadas de dados (Firestore / Storage) e apresentação, evitando múltiplos re-fetches e chamadas redundantes, além de garantir testabilidade através de injeção de dependência e mocks.

## Decisão
1. **Injeção de Dependências**: Adotar `get_it` como Service Locator centralizado em `lib/core/di/service_locator.dart`.
2. **Repository Pattern**: Criar interfaces abstratas (`UserRepository`, `TaskRepository`, `PatientRepository`, `AppointmentRepository`, `ChatRepository`) e implementações no Firestore em `lib/repositories/`.
3. **Gerenciamento de Estado**: Adotar `provider` (`ChangeNotifier`, `MultiProvider`, `Consumer`, `Selector`) para estados compartilhados:
   - `UserProvider` (Perfil, auth state, preferências)
   - `TaskProvider` (Tarefas clínicas, status, respostas)
   - `AppointmentProvider` (Consultas e horários)
   - `MoodProvider` (Registros de humor e tendências emocionais)
   - `InviteProvider` (Gestão de convites e links)
   - `PatientProvider` (Gestão de pacientes e vínculos clínicos)
   - `ChatProvider` (Mensagens e contagem de não lidos)
   - `LocaleProvider` (Internacionalização pt-BR / en-US com persistência)

## Consequências
- Código limpo, desacoplado e de fácil manutenção.
- Facilidade para escrever testes unitários, testes de widgets e testes de integração com 100% de previsibilidade.
