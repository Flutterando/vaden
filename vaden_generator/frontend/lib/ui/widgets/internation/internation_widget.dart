import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../../../config/dependencies.dart';
import '../../../viewmodels/main_viewmodels.dart';
import '../../core/ui/buttons/vaden_dropdown.dart';

enum I18n {
  enUS(Locale('en', 'US'), 'English'),
  esES(Locale('es', 'ES'), 'Spanish'),
  ptBR(Locale('pt', 'BR'), 'Portuguese');

  final Locale locale;
  final String description;

  const I18n(this.locale, this.description);

  String descriptionI18n() => description.i18n();

  factory I18n.fromLocale(Locale locale) {
    return switch (locale.languageCode) {
      'en' => I18n.enUS,
      'pt' => I18n.ptBR,
      'es' => I18n.esES,
      _ => I18n.enUS,
    };
  }
}

class InternationWidget extends StatelessWidget {
  const InternationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final MainViewmodel mainViewmodel = injector.get<MainViewmodel>();
    final Map<String, I18n> i18nMap = {for (var i18n in I18n.values) i18n.descriptionI18n(): i18n};
    return SizedBox(
      width: 200,
      child: VadenDropdown(
        options: i18nMap.keys.toList(),
        selectedOption: I18n.fromLocale(mainViewmodel.locale).descriptionI18n(),
        onOptionSelected: (language) =>
            mainViewmodel.setLanguageCommand.execute(i18nMap[language]!.locale),
      ),
    );
  }
}
