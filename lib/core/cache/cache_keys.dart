enum CacheKeys {
  // Auth
  accessToken('access_token'),
  refreshToken('refresh_token'),
  user('user'),

  // Onboarding
  onboardingCompleted('onboarding_completed'),

  // Settings
  themeMode('theme_mode'),
  locale('locale'),

  // Feature flags
  notificationsEnabled('notifications_enabled');

  const CacheKeys(this.key);
  final String key;
}
