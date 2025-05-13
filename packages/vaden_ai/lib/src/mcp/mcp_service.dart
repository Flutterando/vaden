import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dart_mcp/server.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:vaden/vaden.dart';

import 'mcp_server.dart';
import 'tool.dart';

class McpService {
  final String communications;
  final String name;
  final String version;
  final String? instructions;

  McpService({
    required this.communications,
    required this.name,
    required this.version,
    this.instructions,
  });

  static McpService withSettings(ApplicationSettings settings) {
    return McpService(
      communications: settings['mcp']['communication'],
      name: settings['mcp']['name'],
      version: settings['mcp']['version'].toString(),
      instructions: settings['mcp']['instructions'],
    );
  }

  void start(AutoInjector injector) {
    final MCP mcp = injector.get<MCP>();
    final List<McpTool> tools = mcp.toolsMaps
        .map((toolMap) => McpTool.fromMap(toolMap, injector: injector))
        .toList();

    _startMcp(communications, tools);
  }

  void _startMcp(String communication, final List<McpTool> tools) {
    MyMcpServer(
      _channel(communication),
      implementation: ServerImplementation(name: name, version: version),
      instructions: instructions,
      tools: tools,
    ).initialized;
  }

  StreamChannel<String> _channel(String communication) {
    if (communication == 'stdio') {
      return StreamChannel.withCloseGuarantee(stdin, stdout)
          .transform(StreamChannelTransformer.fromCodec(utf8))
          .transformStream(const LineSplitter())
          .transformSink(
        StreamSinkTransformer.fromHandlers(
          handleData: (data, sink) {
            sink.add('$data\n');
          },
        ),
      );
    }

    throw Exception('Communication not available');
  }
}
