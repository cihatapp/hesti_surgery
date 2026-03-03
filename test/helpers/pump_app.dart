import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hesti_surgery/core/theme/light/light_theme.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<BlocProvider>? providers,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: LightTheme.instance.theme,
        home: providers != null
            ? MultiBlocProvider(
                providers: providers,
                child: widget,
              )
            : widget,
      ),
    );
  }

  Future<void> pumpAppWithScaffold(
    Widget widget, {
    List<BlocProvider>? providers,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: LightTheme.instance.theme,
        home: Scaffold(
          body: providers != null
              ? MultiBlocProvider(
                  providers: providers,
                  child: widget,
                )
              : widget,
        ),
      ),
    );
  }
}
