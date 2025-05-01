import 'dart:convert';

import 'package:vaden_ai/src/mcp/models/request.dart';

class VadenAiException implements Exception {
  final int code;
  final String massage;
  final dynamic data;
  final McpRequests? requests;
  VadenAiException.parseError({
    this.code = -32700,
    this.massage = 'Parse error',
    this.data,
    this.requests,
  });

  VadenAiException.invalidRequest({
    this.code = -32600,
    this.massage = 'Invalid Request',
    this.data,
    this.requests,
  });
  VadenAiException.methodNotFound({
    this.code = -32601,
    this.massage = 'Method not found',
    this.data,
    this.requests,
  });
  VadenAiException.invalidParams({
    this.code = -32602,
    this.massage = 'Invalid params',
    this.data,
    this.requests,
  });
  VadenAiException.internalError({
    this.code = -32603,
    this.massage = 'Internal error',
    this.data,
    this.requests,
  });
  VadenAiException.serverError({
    required this.code,
    this.massage = 'Server error',
    this.data,
    this.requests,
  }) : assert((code <= -32099 && code >= -32000));

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> error = {
      'code': code,
      'message': massage,
    };
    if (data != null) {
      error.addAll({'data': data});
    }

    return {
      'jsonrpc': requests?.jsonrpc ?? "2.0",
      'id': requests?.id,
      'error': error,
    };
  }

  String toJson() => json.encode(toMap());
}
