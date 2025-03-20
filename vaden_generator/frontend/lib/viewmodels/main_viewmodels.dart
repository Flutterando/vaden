import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

mixin _MainGenerate on ChangeNotifier {
  Locale _locale = Locale('en', 'US');

  Locale get locale => _locale;
  void _setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class MainViewmodel extends ChangeNotifier with _MainGenerate {
  late final setLanguageCommand = Command1<Unit, Locale>(_setLanguage);

  AsyncResult<Unit> _setLanguage(Locale locale) async {
    _setLocale(locale);
    return Success(unit);
  }
}
