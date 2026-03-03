// ignore_for_file: deprecated_member_use

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/localization/supported_locales.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/locale_cubit.dart';
import '../bloc/theme_cubit.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settingsTitle.tr()),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.router.replaceAll([const LoginRoute()]);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Appearance Section
            _buildSectionHeader(context, LocaleKeys.settingsTheme.tr()),
            Card(
              child: Column(
                children: [
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, state) {
                      return ListTile(
                        leading: Icon(
                          state.isDark ? Icons.dark_mode : Icons.light_mode,
                        ),
                        title: Text(LocaleKeys.settingsTheme.tr()),
                        subtitle: Text(_getThemeModeName(context, state.themeMode)),
                        trailing: Switch(
                          value: state.isDark,
                          onChanged: (_) {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                        ),
                        onTap: () => _showThemeDialog(context),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  BlocBuilder<LocaleCubit, LocaleState>(
                    builder: (context, state) {
                      return ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(LocaleKeys.settingsLanguage.tr()),
                        subtitle: Text(state.currentLocale.displayName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageDialog(context),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to profile
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to security settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(LocaleKeys.settingsNotifications.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // About Section
            _buildSectionHeader(context, LocaleKeys.settingsAbout.tr()),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text(LocaleKeys.settingsAbout.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to about
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: Text(LocaleKeys.settingsPrivacy.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Open privacy policy
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(LocaleKeys.settingsTerms.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Open terms of service
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Logout
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: context.colorScheme.error,
                ),
                title: Text(
                  LocaleKeys.authLogout.tr(),
                  style: TextStyle(color: context.colorScheme.error),
                ),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Version
            Center(
              child: Text(
                '${LocaleKeys.settingsVersion.tr()} 1.0.0',
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: context.textTheme.titleSmall,
      ),
    );
  }

  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return LocaleKeys.settingsSystemTheme.tr();
      case ThemeMode.light:
        return LocaleKeys.settingsLightTheme.tr();
      case ThemeMode.dark:
        return LocaleKeys.settingsDarkTheme.tr();
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.settingsTheme.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(LocaleKeys.settingsSystemTheme.tr()),
                value: ThemeMode.system,
                groupValue: context.read<ThemeCubit>().state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().setTheme(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(LocaleKeys.settingsLightTheme.tr()),
                value: ThemeMode.light,
                groupValue: context.read<ThemeCubit>().state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().setTheme(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(LocaleKeys.settingsDarkTheme.tr()),
                value: ThemeMode.dark,
                groupValue: context.read<ThemeCubit>().state.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().setTheme(value);
                    Navigator.pop(dialogContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.settingsLanguage.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SupportedLocale.values.map((locale) {
              return RadioListTile<SupportedLocale>(
                title: Text(locale.displayName),
                subtitle: Text(locale.name),
                value: locale,
                groupValue: localeCubit.state.currentLocale,
                onChanged: (value) {
                  if (value != null) {
                    localeCubit.setLocale(context, value);
                    Navigator.pop(dialogContext);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(LocaleKeys.authLogout.tr()),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(LocaleKeys.commonCancel.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(const LogoutEvent());
              },
              child: Text(
                LocaleKeys.authLogout.tr(),
                style: TextStyle(color: context.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
