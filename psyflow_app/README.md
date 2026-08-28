# 🧠 PsyFlow - Plataforma de Cuidado em Saúde Mental

O **PsyFlow** é uma aplicação completa e multiplataforma (Android, iOS, Web) desenvolvida em Flutter para conectar psicólogos e pacientes, potencializando a intervenção clínica contínua com acompanhamento de humor, tarefas terapêuticas baseadas em TCC, escalas clínicas validadas, relatórios de progresso em PDF e comunicação segura.

---

## 🚀 Funcionalidades Principais

- 🔐 **Autenticação Segura**: Suporte a login, registro com validações e recuperação de senha.
- 👥 **Vínculo Clínico por Convite**: Psicólogos geram códigos de convite compartilháveis para conectar pacientes.
- 📊 **Monitoramento Diário de Humor**: Registros com indicadores de humor, ansiedade, energia, sono e estresse, com mapa emocional histórico.
- 📝 **Tarefas & Prescrições Terapêuticas**: Criação, acompanhamento e registro de conclusões com reflexões e reestruturação cognitiva.
- 📋 **Escalas Clínicas Validadas**: Aplicação e interpretação automática de instrumentos como PHQ-9 (Depressão), GAD-7 (Ansiedade) e SNAP-IV (TDAH).
- 📑 **Relatórios Clínicos em PDF**: Geração e exportação confidencial de relatórios de progresso terapêutico (`pdf` + `printing`).
- 🛡️ **Conformidade LGPD / GDPR**: Exportação de dados pessoais completos em formato JSON portável.
- 🌐 **Internacionalização (i18n)**: Suporte dinâmico com persistência para Português (Brasil) e Inglês (EUA).
- 💬 **Comunicação Direta & Notificações**: Gestão de chat e suporte a notificações push via Firebase Cloud Messaging.

---

## 🏛️ Arquitetura & Tecnologias

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Backend & Cloud**: [Firebase](https://firebase.google.com) (Auth, Cloud Firestore, Storage, Cloud Messaging, Analytics, Crashlytics)
- **Gerenciamento de Estado**: [Provider](https://pub.dev/packages/provider) (`MultiProvider`, `ChangeNotifier`, `Consumer`, `Selector`)
- **Injeção de Dependências**: [GetIt](https://pub.dev/packages/get_it) (`ServiceLocator`)
- **Padrão de Projeto**: Repository Pattern com interfaces abstratas e implementação desacoplada.
- **Design System**: Sistema proprietário de tokens de design (`AppColors`, `AppTypography`, `AppSpacing`, `AppElevation`, `AppBorderRadius`) e componentes reutilizáveis (`DSButton`, `DSCard`, `DSTextField`, `DSDialog`).
- **CI/CD**: GitHub Actions automatizado para validação de linter e execução de suíte de testes em cada PR/push.

---

## 🛠️ Como Executar

### Pré-requisitos
- Flutter SDK (versão estável >= 3.11.5)
- Git

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/PriCardoso/PsyFlow.git
cd psyflow_app

# 2. Instale as dependências
flutter pub get

# 3. Execute o aplicativo
flutter run
```

---

## 🧪 Testes Automatizados

A aplicação conta com uma suíte abrangente de testes unitários, testes de widgets e testes de integração:

```bash
# Executar todos os testes com cobertura
flutter test --coverage

# Executar análise estática de código
flutter analyze
```

---

## 📚 Documentação Técnica Adicional

- [Guia de Contribuição (CONTRIBUTING.md)](file:///d:/cursos/PsyFlow/psyflow_app/CONTRIBUTING.md)
- [ADR 001: Migração para o ecossistema Firebase](file:///d:/cursos/PsyFlow/psyflow_app/docs/adr/ADR-001-firebase-migration.md)
- [ADR 002: Gerenciamento de Estado e Repository Pattern](file:///d:/cursos/PsyFlow/psyflow_app/docs/adr/ADR-002-state-management-and-repository-pattern.md)
