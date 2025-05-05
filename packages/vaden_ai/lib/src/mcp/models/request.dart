class McpRequests {
  final String jsonrpc;
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;
  McpRequests({
    required this.jsonrpc,
    required this.id,
    required this.method,
    this.params,
  });
}
