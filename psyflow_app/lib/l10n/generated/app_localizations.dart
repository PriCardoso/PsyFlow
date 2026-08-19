import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'PsyFlow'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao PsyFlow'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get register;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci a senha'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In pt, this message translates to:
  /// **'Redefinir senha'**
  String get resetPassword;

  /// No description provided for @fullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get phone;

  /// No description provided for @crp.
  ///
  /// In pt, this message translates to:
  /// **'CRP'**
  String get crp;

  /// No description provided for @bio.
  ///
  /// In pt, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @role.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get role;

  /// No description provided for @patient.
  ///
  /// In pt, this message translates to:
  /// **'Paciente'**
  String get patient;

  /// No description provided for @psychologist.
  ///
  /// In pt, this message translates to:
  /// **'Psicólogo'**
  String get psychologist;

  /// No description provided for @professional.
  ///
  /// In pt, this message translates to:
  /// **'Profissional'**
  String get professional;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveChanges;

  /// No description provided for @editProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get dashboard;

  /// No description provided for @appointments.
  ///
  /// In pt, this message translates to:
  /// **'Consultas'**
  String get appointments;

  /// No description provided for @tasks.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get tasks;

  /// No description provided for @mood.
  ///
  /// In pt, this message translates to:
  /// **'Humor'**
  String get mood;

  /// No description provided for @moodHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de humor'**
  String get moodHistory;

  /// No description provided for @myPsychologist.
  ///
  /// In pt, this message translates to:
  /// **'Meu psicólogo'**
  String get myPsychologist;

  /// No description provided for @myPatients.
  ///
  /// In pt, this message translates to:
  /// **'Meus pacientes'**
  String get myPatients;

  /// No description provided for @schedule.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get schedule;

  /// No description provided for @availability.
  ///
  /// In pt, this message translates to:
  /// **'Disponibilidade'**
  String get availability;

  /// No description provided for @addAvailability.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar horário'**
  String get addAvailability;

  /// No description provided for @bookAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Agendar consulta'**
  String get bookAppointment;

  /// No description provided for @cancelAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar consulta'**
  String get cancelAppointment;

  /// No description provided for @upcomingAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Próxima consulta'**
  String get upcomingAppointment;

  /// No description provided for @noAppointments.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma consulta agendada'**
  String get noAppointments;

  /// No description provided for @noTasks.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tarefa atribuída'**
  String get noTasks;

  /// No description provided for @completeTask.
  ///
  /// In pt, this message translates to:
  /// **'Concluir tarefa'**
  String get completeTask;

  /// No description provided for @taskCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Tarefa concluída'**
  String get taskCompleted;

  /// No description provided for @pending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get completed;

  /// No description provided for @moodEntry.
  ///
  /// In pt, this message translates to:
  /// **'Registro de humor'**
  String get moodEntry;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In pt, this message translates to:
  /// **'Como você está se sentindo hoje?'**
  String get howAreYouFeeling;

  /// No description provided for @anxiety.
  ///
  /// In pt, this message translates to:
  /// **'Ansiedade'**
  String get anxiety;

  /// No description provided for @energy.
  ///
  /// In pt, this message translates to:
  /// **'Energia'**
  String get energy;

  /// No description provided for @notes.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get notes;

  /// No description provided for @submit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get submit;

  /// No description provided for @alreadyRegisteredToday.
  ///
  /// In pt, this message translates to:
  /// **'Você já registrou seu humor hoje'**
  String get alreadyRegisteredToday;

  /// No description provided for @inviteCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de convite'**
  String get inviteCode;

  /// No description provided for @generateInvite.
  ///
  /// In pt, this message translates to:
  /// **'Gerar convite'**
  String get generateInvite;

  /// No description provided for @useInvite.
  ///
  /// In pt, this message translates to:
  /// **'Usar convite'**
  String get useInvite;

  /// No description provided for @linkPatient.
  ///
  /// In pt, this message translates to:
  /// **'Vincular paciente'**
  String get linkPatient;

  /// No description provided for @unlinkPatient.
  ///
  /// In pt, this message translates to:
  /// **'Desvincular paciente'**
  String get unlinkPatient;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @success.
  ///
  /// In pt, this message translates to:
  /// **'Sucesso'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @networkError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão. Verifique sua internet.'**
  String get networkError;

  /// No description provided for @permissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão para esta ação'**
  String get permissionDenied;

  /// No description provided for @notFound.
  ///
  /// In pt, this message translates to:
  /// **'Não encontrado'**
  String get notFound;

  /// No description provided for @validationError.
  ///
  /// In pt, this message translates to:
  /// **'Dados inválidos'**
  String get validationError;

  /// No description provided for @authError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de autenticação'**
  String get authError;

  /// No description provided for @unknownError.
  ///
  /// In pt, this message translates to:
  /// **'Erro desconhecido'**
  String get unknownError;

  /// No description provided for @profileIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'Perfil incompleto. Complete seu cadastro.'**
  String get profileIncomplete;

  /// No description provided for @inviteExpired.
  ///
  /// In pt, this message translates to:
  /// **'Este código expirou. Peça um novo ao seu psicólogo.'**
  String get inviteExpired;

  /// No description provided for @inviteInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido ou já utilizado.'**
  String get inviteInvalid;

  /// No description provided for @cannotUseOwnInvite.
  ///
  /// In pt, this message translates to:
  /// **'Você não pode usar seu próprio convite.'**
  String get cannotUseOwnInvite;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @darkMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo escuro'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo claro'**
  String get lightMode;

  /// No description provided for @notifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações push'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações por e-mail'**
  String get emailNotifications;

  /// No description provided for @privacy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get privacy;

  /// No description provided for @termsOfService.
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get privacyPolicy;

  /// No description provided for @deleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get deleteAccount;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.'**
  String get confirmDeleteAccount;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @next.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get finish;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @continueAction.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get sort;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In pt, this message translates to:
  /// **'Todo o período'**
  String get allTime;

  /// No description provided for @week.
  ///
  /// In pt, this message translates to:
  /// **'Semana'**
  String get week;

  /// No description provided for @month.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get month;

  /// No description provided for @year.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get year;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
