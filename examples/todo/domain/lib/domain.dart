import 'package:domain/models/default_message.dart';
import 'package:domain/models/todo.dart';
import 'package:vaden_core/vaden_core.dart';

export 'models/default_message.dart';
export 'models/todo.dart';

@VadenModule([
  DefaultMessage,
  Todo,
  TodoCreate,
])
class DomainModule {}
