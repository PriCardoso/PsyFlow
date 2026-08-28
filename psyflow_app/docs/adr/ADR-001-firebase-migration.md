# ADR 001: Migração de Supabase para Firebase Ecosystem

## Status
Aceito

## Contexto
O PsyFlow anteriormente utilizava Supabase (PostgreSQL + Auth + Storage). Para viabilizar uma integração móvel mais fluida, melhor suporte a sincronização offline, notificações push nativas via FCM e analytics integrado, optou-se pela migração completa para o ecossistema Firebase (Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging, Firebase Analytics e Firebase Crashlytics).

## Decisão
1. **Autenticação**: Uso do `firebase_auth` com suporte a e-mail/senha e Google Sign-In.
2. **Banco de Dados**: Migração para Cloud Firestore com modelos orientados a documentos, índices compostos definidos em `firestore.indexes.json` e regras de segurança rígidas em `firestore.rules`.
3. **Armazenamento**: Migração para Firebase Storage com caminhos seguros segregados por `user_id`.
4. **Mensageria e Notificações**: `firebase_messaging` com tópicos `patient_{uid}` e `psychologist_{uid}`.
5. **Observabilidade**: `firebase_analytics` e `firebase_crashlytics` para telemetria, detecção de erros em tempo real e monitoramento de engajamento clínico.

## Consequências
- Alta disponibilidade com suporte nativo a cache e offline-first do Firestore.
- Redução de latência em streams em tempo real.
- Maior integração com serviços Google para mobile.
