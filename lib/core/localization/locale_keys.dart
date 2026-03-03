/// Type-safe translation keys for easy_localization
/// Usage: LocaleKeys.auth_login.tr()
abstract class LocaleKeys {
  // App
  static const String appName = 'app_name';

  // Common
  static const String commonOk = 'common.ok';
  static const String commonCancel = 'common.cancel';
  static const String commonSave = 'common.save';
  static const String commonDelete = 'common.delete';
  static const String commonEdit = 'common.edit';
  static const String commonClose = 'common.close';
  static const String commonBack = 'common.back';
  static const String commonNext = 'common.next';
  static const String commonDone = 'common.done';
  static const String commonLoading = 'common.loading';
  static const String commonRetry = 'common.retry';
  static const String commonError = 'common.error';
  static const String commonSuccess = 'common.success';
  static const String commonWarning = 'common.warning';

  // Auth
  static const String authLogin = 'auth.login';
  static const String authRegister = 'auth.register';
  static const String authLogout = 'auth.logout';
  static const String authEmail = 'auth.email';
  static const String authPassword = 'auth.password';
  static const String authConfirmPassword = 'auth.confirm_password';
  static const String authForgotPassword = 'auth.forgot_password';
  static const String authDontHaveAccount = 'auth.dont_have_account';
  static const String authAlreadyHaveAccount = 'auth.already_have_account';
  static const String authLoginSuccess = 'auth.login_success';
  static const String authRegisterSuccess = 'auth.register_success';
  static const String authLogoutSuccess = 'auth.logout_success';

  // Validation
  static const String validationRequiredField = 'validation.required_field';
  static const String validationInvalidEmail = 'validation.invalid_email';
  static const String validationPasswordTooShort = 'validation.password_too_short';
  static const String validationPasswordsDontMatch = 'validation.passwords_dont_match';

  // Onboarding
  static const String onboardingTitle1 = 'onboarding.title_1';
  static const String onboardingDescription1 = 'onboarding.description_1';
  static const String onboardingTitle2 = 'onboarding.title_2';
  static const String onboardingDescription2 = 'onboarding.description_2';
  static const String onboardingTitle3 = 'onboarding.title_3';
  static const String onboardingDescription3 = 'onboarding.description_3';
  static const String onboardingSkip = 'onboarding.skip';
  static const String onboardingGetStarted = 'onboarding.get_started';

  // Dashboard
  static const String dashboardTitle = 'dashboard.title';
  static const String dashboardWelcome = 'dashboard.welcome';
  static const String dashboardQuickActions = 'dashboard.quick_actions';
  static const String dashboardRecentCases = 'dashboard.recent_cases';

  // Patients
  static const String patientsTitle = 'patients.title';
  static const String patientsNewPatient = 'patients.new_patient';
  static const String patientsFirstName = 'patients.first_name';
  static const String patientsLastName = 'patients.last_name';

  // Surgery Case
  static const String surgeryCaseTitle = 'surgery_case.title';
  static const String surgeryCaseNewCase = 'surgery_case.new_case';

  // Photo Capture
  static const String photoCaptureTitle = 'photo_capture.title';

  // 3D Model
  static const String model3dTitle = 'model_3d.title';
  static const String model3dGenerate = 'model_3d.generate';

  // Morphing
  static const String morphingTitle = 'morphing.title';

  // Measurements
  static const String measurementsTitle = 'measurements.title';

  // Report
  static const String reportTitle = 'report.title';
  static const String reportGenerate = 'report.generate_report';

  // Settings
  static const String settingsTitle = 'settings.title';
  static const String settingsTheme = 'settings.theme';
  static const String settingsLanguage = 'settings.language';
  static const String settingsNotifications = 'settings.notifications';
  static const String settingsPrivacy = 'settings.privacy';
  static const String settingsTerms = 'settings.terms';
  static const String settingsAbout = 'settings.about';
  static const String settingsVersion = 'settings.version';
  static const String settingsLightTheme = 'settings.light_theme';
  static const String settingsDarkTheme = 'settings.dark_theme';
  static const String settingsSystemTheme = 'settings.system_theme';
  static const String settingsAiModel = 'settings.ai_model';

  // Errors
  static const String errorsServerError = 'errors.server_error';
  static const String errorsNetworkError = 'errors.network_error';
  static const String errorsUnknownError = 'errors.unknown_error';
  static const String errorsSessionExpired = 'errors.session_expired';
  static const String errorsPhotoUploadFailed = 'errors.photo_upload_failed';
  static const String errorsReconstructionFailed = 'errors.reconstruction_failed';
}
