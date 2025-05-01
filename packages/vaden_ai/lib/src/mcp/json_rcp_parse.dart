import 'dart:convert';

import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_ai/src/mcp/exceptions.dart';
import 'package:vaden_ai/src/mcp/models/request.dart';

import 'models/response.dart';

class JsonRcpParse {
  static AsyncResult<McpRequests> fromRequest(Request request) async {
    try {
      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final McpRequests mcpRequests = McpRequests(
        jsonrpc: bodyJson['jsonrpc'],
        id: bodyJson['id'],
        method: bodyJson['method'],
        params: bodyJson['params'],
      );

      return _validateMcpRequests(mcpRequests);
    } catch (e) {
      return Failure(VadenAiException.parseError());
    }
  }

  static AsyncResult<McpRequests> _validateMcpRequests(
      McpRequests mcpRequests) async {
    final List<String> versions = ['2.0'];
    if (!versions.contains(mcpRequests.jsonrpc)) {
      return Failure(VadenAiException.invalidRequest());
    }
    if (mcpRequests.id is! String &&
        mcpRequests.id is! int &&
        mcpRequests.id != null) {
      return Failure(VadenAiException.invalidRequest());
    }
    return Success(mcpRequests);
  }
}

extension JsonRcpParseExtension on AsyncResult<McpResponse> {
  Future<Response> toMcpResponse() async {
    return fold(
      (s) => Response.ok(s.toJson()),
      (e) {
        if (e is VadenAiException) {
          return Response.ok(e.toJson());
        }
        return Response.ok(
            VadenAiException.serverError(code: -32000, data: e).toJson());
      },
    );
  }
}
