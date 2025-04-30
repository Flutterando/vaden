import 'package:vaden/vaden.dart';

import 'message.dart';

@DTO()
class McpRequests extends McpMessage {
  final dynamic id;
  final String method;
  final Object? params;
  McpRequests({
    super.jsonrpc,
    required this.id,
    required this.method,
    this.params,
  }) : assert((id is String || id is int || id == null));
}
