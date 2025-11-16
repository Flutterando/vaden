/// MCP (Model Context Protocol) message models for JSON-RPC communication
library;

class MCPRequest {
  final String jsonrpc;
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;

  MCPRequest({
    this.jsonrpc = '2.0',
    required this.id,
    required this.method,
    this.params,
  });

  factory MCPRequest.fromJson(Map<String, dynamic> json) {
    return MCPRequest(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      id: json['id'],
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      'method': method,
      if (params != null) 'params': params,
    };
  }
}

class MCPResponse {
  final String jsonrpc;
  final dynamic id;
  final dynamic result;
  final MCPError? error;

  MCPResponse({
    this.jsonrpc = '2.0',
    required this.id,
    this.result,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'id': id,
      if (result != null) 'result': result,
      if (error != null) 'error': error!.toJson(),
    };
  }
}

class MCPError {
  final int code;
  final String message;
  final dynamic data;

  MCPError({
    required this.code,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (data != null) 'data': data,
    };
  }
}

class MCPNotification {
  final String jsonrpc;
  final String method;
  final Map<String, dynamic>? params;

  MCPNotification({
    this.jsonrpc = '2.0',
    required this.method,
    this.params,
  });

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      if (params != null) 'params': params,
    };
  }
}

class MCPToolInfo {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;

  MCPToolInfo({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
    };
  }
}

class MCPResourceInfo {
  final String uri;
  final String name;
  final String? description;
  final String? mimeType;

  MCPResourceInfo({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'name': name,
      if (description != null) 'description': description,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }
}
