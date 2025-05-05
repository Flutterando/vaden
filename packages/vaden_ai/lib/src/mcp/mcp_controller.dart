import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_ai/src/mcp/exceptions.dart';

import 'json_rcp_parse.dart';
import 'models/capability.dart';
import 'models/request.dart';
import 'models/response.dart';
import 'models/tool.dart';

@Api(tag: 'VadenAI - MCP', description: 'MCP endpoints')
@Controller('/mcp')
class MCPController {
  MCPController();

  @ApiOperation(summary: 'MCP communication')
  @ApiResponse(200,
      description: 'MCP successfully',
      content: ApiContent(type: 'application/json', schema: McpResponse))
  @Post()
  Future<Response> mcp(Request request) async {
    return JsonRcpParse.fromRequest(request) //
        .flatMap(_switch)
        .toJsonRcpResponse();
  }

  //So teste
  final List<Capability> capability = [];
  AsyncResult<McpResponse> _switch(McpRequests request) async {
    if (request.id == null) {
      return Success(McpResponse(jsonrpc: request.jsonrpc, id: request.id));
    }

    return switch (request.method) {
      'tools/list' => _toolsList(request),
      'tools/call' => _toolsCall(request),
      _ => Failure(VadenAiException.methodNotFound(requests: request)),
    };
  }

  AsyncResult<McpResponse> _toolsList(McpRequests request) async {
    List<McpTool> tools = capability.whereType<McpTool>().toList();

    return Success(McpResponse(
        jsonrpc: request.jsonrpc,
        id: request.id,
        result: {'tools': tools.map((e) => e.toMap())}));
  }

  AsyncResult<McpResponse> _toolsCall(McpRequests request) async {
    final String? toolName = request.params?['name'];

    List<McpTool> tools = capability //
        .whereType<McpTool>()
        .where((e) => e.name == toolName)
        .toList();

    if (tools.isEmpty) {
      return Failure(VadenAiException.invalidRequest(requests: request));
    }

    Map<String, dynamic>? result =
        await tools.first.run(request.params?['arguments']);

    return Success(
        McpResponse(jsonrpc: request.jsonrpc, id: request.id, result: result));
  }
}
