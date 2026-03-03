import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../core/cache/cache_keys.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Wait for splash duration
    await Future<void>.delayed(AppDurations.splashDuration);

    if (!mounted) return;

    // Check if onboarding is completed
    final cacheManager = sl<CacheManager>();
    final onboardingCompleted =
        cacheManager.getBool(CacheKeys.onboardingCompleted) ?? false;

    if (!onboardingCompleted) {
      await context.router.replace(const OnboardingRoute());
      return;
    }

    // Check auth status
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.router.replaceAll([const MainNavigationRoute()]);
        } else if (state is Unauthenticated) {
          context.router.replaceAll([const LoginRoute()]);
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Icon(
                Icons.flutter_dash,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'Flutter Boilerplate',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 48),
              // Loading indicator
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
