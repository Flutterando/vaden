class McpRequests {
  final String jsonrpc;
  final dynamic id;
  final String method;
  final Object? params;
  McpRequests({
    required this.jsonrpc,
    required this.id,
    required this.method,
    this.params,
  });
}
