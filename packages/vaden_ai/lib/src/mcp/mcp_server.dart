import 'dart:async';

import 'package:dart_mcp/server.dart';

import 'tool.dart';

final class MyMcpServer extends MCPServer with ToolsSupport {
  final List<McpTool> tools;

  MyMcpServer(super.channel,
      {required this.tools, required super.implementation, super.instructions})
      : super.fromStreamChannel();

  @override
  FutureOr<InitializeResult> initialize(InitializeRequest request) {
    for (var tool in tools) {
      registerTool(tool.tool, tool.impl);
    }
    return super.initialize(request);
  }
}
