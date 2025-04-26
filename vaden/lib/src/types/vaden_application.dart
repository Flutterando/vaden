import 'dart:io';

import 'package:vaden/vaden.dart';

abstract class VadenApplication {
  Future<HttpServer> run(List<String> args);
  Future<void> setup();

  Injector get injector;

  Router get router;

  static late final VadenApplication instance;

  static void registerInstance(VadenApplication app) {
    instance = app;
  }
}
