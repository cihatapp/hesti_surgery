import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_router.dart';
import 'core/offline/connectivity_cubit.dart';
import 'core/theme/dark/dark_theme.dart';
import 'core/theme/light/light_theme.dart';
import 'core/widgets/offline_indicator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/settings/presentation/bloc/locale_cubit.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => sl<LocaleCubit>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ConnectivityCubit>(create: (_) => sl<ConnectivityCubit>()),
        // Add more global BLoCs here
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ConnectivityListener(
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Hesti 3D',
              // Localization
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              // Theme
              theme: LightTheme.instance.theme,
              darkTheme: DarkTheme.instance.theme,
              themeMode: themeState.themeMode,
              // Routing
              routerConfig: sl<AppRouter>().config(),
            ),
          );
        },
      ),
    );
  }
}
