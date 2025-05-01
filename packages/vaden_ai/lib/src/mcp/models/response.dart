import 'dart:convert';

class McpResponse {
  final String jsonrpc;
  final dynamic id;
  final Map<String, dynamic>? result;
  McpResponse({
    required this.jsonrpc,
    required this.id,
    this.result,
  });

  Map<String, dynamic> toMap() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      'result': result,
    };
  }

  factory McpResponse.fromMap(Map<String, dynamic> map) {
    return McpResponse(
      jsonrpc: map['jsonrpc'] ?? '',
      id: map['id'],
      result: Map<String, dynamic>.from(map['result']),
    );
  }

  String toJson() => json.encode(toMap());

  factory McpResponse.fromJson(String source) =>
      McpResponse.fromMap(json.decode(source));
}
