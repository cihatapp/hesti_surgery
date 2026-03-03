import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../config/routes/app_router.dart';

enum NavigationRoute {
  splash,
  onboarding,
  login,
  register,
  mainNavigation,
  home,
  settings,
}

class NavigationManager {
  NavigationManager._internal();
  static NavigationManager? _instance;

  static NavigationManager get instance {
    _instance ??= NavigationManager._internal();
    return _instance!;
  }

  factory NavigationManager() => instance;

  late final AppRouter _router = AppRouter();

  AppRouter get router => _router;

  // Get route by enum
  PageRouteInfo _getRoute(NavigationRoute route) {
    switch (route) {
      case NavigationRoute.splash:
        return const SplashRoute();
      case NavigationRoute.onboarding:
        return const OnboardingRoute();
      case NavigationRoute.login:
        return const LoginRoute();
      case NavigationRoute.register:
        return const RegisterRoute();
      case NavigationRoute.mainNavigation:
        return const MainNavigationRoute();
      case NavigationRoute.home:
        return const HomeRoute();
      case NavigationRoute.settings:
        return const SettingsRoute();
    }
  }

  // Navigation methods
  Future<T?> push<T extends Object?>(NavigationRoute route) {
    return _router.push<T>(_getRoute(route));
  }

  Future<T?> replace<T extends Object?>(NavigationRoute route) {
    return _router.replace<T>(_getRoute(route));
  }

  Future<void> replaceAll(List<NavigationRoute> routes) {
    return _router.replaceAll(routes.map(_getRoute).toList());
  }

  void pop<T extends Object?>([T? result]) {
    _router.maybePop(result);
  }

  void popUntilRoot() {
    _router.popUntilRoot();
  }

  bool canPop() {
    return _router.canPop();
  }

  // Tab navigation (for bottom nav)
  void navigateToTab(BuildContext context, int index) {
    final tabsRouter = AutoTabsRouter.of(context);
    tabsRouter.setActiveIndex(index);
  }

  // Navigate and clear stack
  Future<void> navigateAndClearStack(NavigationRoute route) {
    return _router.replaceAll([_getRoute(route)]);
  }
}
