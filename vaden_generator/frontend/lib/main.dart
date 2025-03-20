import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localization/localization.dart';
import 'config/dependencies.dart';
import 'ui/core/themes/theme.dart';
import 'ui/generate/generate_page.dart';
import 'ui/widgets/internation/internation_widget.dart';
import 'viewmodels/main_viewmodels.dart';

void main() {
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
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return ListenableBuilder(
      listenable: viewmodel,
      builder: (context, child) {
        return MaterialApp(
          title: 'Vaden generator',
          themeMode: ThemeMode.system,
          theme: lightTheme,
          darkTheme: dartTheme,
          locale: viewmodel.locale,
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
          home: const GeneratePage(),
        );
      },
    );
  }
}
