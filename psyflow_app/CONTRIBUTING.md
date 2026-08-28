# Guia de Contribuição - PsyFlow

Obrigado pelo interesse em contribuir com o **PsyFlow**, a plataforma multidisciplinar de cuidado em saúde mental conectando psicólogos e pacientes.

## Padrões de Código e Arquitetura

1. **Arquitetura em Camadas**:
   - `lib/core/`: Componentes transversais, design system, injeção de dependências, tratamento de erros, utilitários.
   - `lib/repositories/`: Interfaces abstratas e implementações de persistência.
   - `lib/core/providers/`: Gerenciamento de estado global com `ChangeNotifier` e `Provider`.
   - `lib/features/`: Módulos funcionais e telas (Auth, Dashboard, Consultas, Tarefas, Humor, etc.).
   - `lib/models/`: Modelos de domínio com serialização (`toMap`, `fromMap`).

2. **Design System & Estilo**:
   - Utilize sempre os componentes padronizados do Design System (`DSButton`, `DSCard`, `DSTextField`, `AppElevation`, `AppSpacing`, `AppColors`).
   - Evite cores ou dimensões hardcoded nas interfaces.

3. **Internacionalização (i18n)**:
   - Todas as mensagens e textos devem estar presentes em `lib/l10n/app_pt.arb` e `lib/l10n/app_en.arb`.

4. **Tratamento de Erros**:
   - Utilize as subclasses de `AppException` (`NetworkException`, `AuthException`, `ValidationException`, `PermissionException`, `NotFoundException`).
   - Utilize `ErrorHandler.showError(context, error)` para feedback visual consistente.

## Fluxo de Desenvolvimento e Testes

Antes de abrir qualquer Pull Request:

```bash
# 1. Obter dependências
flutter pub get

# 2. Executar análise estática
flutter analyze

# 3. Executar toda a suíte de testes automatizados
flutter test
```
