import 'dart:async';

import 'package:vaden/vaden.dart';
import 'package:vaden_ai/vaden_ai.dart';

@VadenModule([])
class VadenAiMcp extends CommonModule {
  @override
  FutureOr<void> register(Router router, AutoInjector injector) async {
    injector.get<McpService>().start(injector);
  }
}
