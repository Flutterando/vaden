import 'package:vaden/src/types/vaden_application.dart';

abstract class ApplicationRunner {
  Future<void> run(VadenApplication app);
}
