import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:localization/localization.dart';

import 'config/dependencies.dart';
import 'main_viewmodels.dart';
import 'routes.dart';
import 'ui/core/themes/theme.dart';
import 'ui/widgets/internation/internation_widget.dart';

void main() {
  usePathUrlStrategy();
  setupInjection();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final MainViewmodel viewmodel = injector.get<MainViewmodel>();
  @override
  void initState() {
    super.initState();

    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewmodel,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Vaden generator',
          themeMode: ThemeMode.system,
          theme: lightTheme,
          darkTheme: dartTheme,
          locale: viewmodel.locale,
          routerConfig: router,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            LocalJsonLocalization.delegate,
          ],
          supportedLocales: I18n.values.map((value) => value.locale).toList(),
          localeResolutionCallback: (locale, supportedLocales) {
            Locale defaultLocale = Locale('en', 'US');

            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (locale.languageCode == supportedLocale.languageCode) {
                  defaultLocale = supportedLocale;
                  break;
                }
              }
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewmodel.setLanguageCommand.execute(defaultLocale);
            });

            return defaultLocale;
          },
        );
      },
    );
  }
}
