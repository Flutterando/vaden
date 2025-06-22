import 'package:auto_injector/auto_injector.dart';

abstract class VadenApplication {
  AutoInjector get injector;
  Future<void> setup();
}
