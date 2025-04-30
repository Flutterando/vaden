import 'package:vaden/vaden.dart';

import '../exceptions.dart';
import 'message.dart';

@DTO()
class McpResponse extends McpMessage {
  final dynamic id;
  final String method;
  final Object? result;
  @UseParse(VadenAiExceptionParse)
  final VadenAiException? error;
  McpResponse({
    super.jsonrpc,
    required this.id,
    required this.method,
    this.result,
    this.error,
  }) : assert((id is String || id is int));
}
