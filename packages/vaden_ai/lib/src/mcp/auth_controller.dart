import 'dart:convert';

import 'package:vaden/vaden.dart';

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
  Future<McpResponse> mcp(@Body() McpRequests requests) async {
    return userDetails;
  }
}
