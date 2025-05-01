import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

import 'json_rcp_parse.dart';
import 'models/request.dart';
import 'models/response.dart';

@Api(tag: 'VadenAI - MCP', description: 'MCP endpoints')
@Controller('/mcp')
class MCPController {
  MCPController();

  @ApiOperation(summary: 'MCP communication')
  @ApiResponse(200,
      description: 'MCP successfully',
      content: ApiContent(type: 'application/json', schema: McpResponse))
  @Get()
  Future<Response> mcp(Request request) async {
    return JsonRcpParse.fromRequest(request) //
        .flatMap(_teste)
        .toMcpResponse();
  }

//So teste
  AsyncResult<McpResponse> _teste(McpRequests request) async {
    return Success(
        McpResponse(jsonrpc: request.jsonrpc, id: request.id, result: {}));
  }
}
