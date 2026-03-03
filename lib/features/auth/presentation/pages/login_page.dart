import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _clinicCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  void dispose() {
    _clinicCodeController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ClinicCodeLoginEvent(
              clinicCode: _clinicCodeController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.router.replaceAll([const MainNavigationRoute()]);
          } else if (state is AuthError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Hesti Surgery',
                      style: context.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Klinik kodunuzu girerek devam edin',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Clinic Code Field
                    AppTextField(
                      controller: _clinicCodeController,
                      labelText: 'Klinik Kodu',
                      hintText: 'Örn: HESTI2024',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onLoginPressed(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen klinik kodunuzu girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton.primary(
                          text: 'Giriş Yap',
                          isExpanded: true,
                          isLoading: state is AuthLoading,
                          onPressed: _onLoginPressed,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
