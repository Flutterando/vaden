import 'package:domain/domain.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@VadenModule([
  DomainModule,
  VadenSecurity,
])
class AppModule {}
