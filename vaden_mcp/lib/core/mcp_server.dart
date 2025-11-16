import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/mcp_message.dart';

/// MCP Server implementation following the Model Context Protocol
class MCPServer {
  final Map<String, MCPToolHandler> _tools = {};
  final Map<String, MCPResourceHandler> _resources = {};
  final String _serverName;
  final String _serverVersion;

  MCPServer({
    required String serverName,
    required String serverVersion,
  })  : _serverName = serverName,
        _serverVersion = serverVersion;

  /// Register a tool
  void registerTool(String name, MCPToolHandler handler, MCPToolInfo info) {
    _tools[name] = handler;
    _tools['${name}_info'] = (params) async => info.toJson();
  }

  /// Register a resource
  void registerResource(String uri, MCPResourceHandler handler) {
    _resources[uri] = handler;
  }

  /// Start the MCP server (stdio mode)
  Future<void> start() async {
    stderr.writeln('[$_serverName v$_serverVersion] MCP Server starting...');

    // Send server info
    _sendNotification('initialized', {
      'serverName': _serverName,
      'version': _serverVersion,
      'capabilities': {
        'tools': true,
        'resources': true,
      },
    });

    // Listen to stdin
    await for (final line in stdin.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;

      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        await _handleRequest(json);
      } catch (e, stack) {
        stderr.writeln('Error processing request: $e');
        stderr.writeln(stack);
      }
    }
  }

  /// Handle incoming request
  Future<void> _handleRequest(Map<String, dynamic> json) async {
    try {
      final request = MCPRequest.fromJson(json);

      // Handle different methods
      switch (request.method) {
        case 'initialize':
          await _handleInitialize(request);
          break;
        case 'tools/list':
          await _handleToolsList(request);
          break;
        case 'tools/call':
          await _handleToolCall(request);
          break;
        case 'resources/list':
          await _handleResourcesList(request);
          break;
        case 'resources/read':
          await _handleResourceRead(request);
          break;
        default:
          _sendError(request.id, -32601, 'Method not found: ${request.method}');
      }
    } catch (e, stack) {
      stderr.writeln('Error handling request: $e');
      stderr.writeln(stack);
      _sendError(null, -32603, 'Internal error: $e');
    }
  }

  /// Handle initialize request
  Future<void> _handleInitialize(MCPRequest request) async {
    _sendResponse(request.id, {
      'protocolVersion': '2024-11-05',
      'serverInfo': {
        'name': _serverName,
        'version': _serverVersion,
      },
      'capabilities': {
        'tools': {},
        'resources': {},
      },
    });
  }

  /// Handle tools list request
  Future<void> _handleToolsList(MCPRequest request) async {
    final toolsList = <Map<String, dynamic>>[];

    for (final toolName in _tools.keys) {
      if (toolName.endsWith('_info')) continue;

      final infoKey = '${toolName}_info';
      if (_tools.containsKey(infoKey)) {
        final info = await _tools[infoKey]!({});
        toolsList.add(info as Map<String, dynamic>);
      }
    }

    _sendResponse(request.id, {'tools': toolsList});
  }

  /// Handle tool call request
  Future<void> _handleToolCall(MCPRequest request) async {
    final params = request.params ?? {};
    final toolName = params['name'] as String?;

    if (toolName == null) {
      _sendError(request.id, -32602, 'Tool name is required');
      return;
    }

    final handler = _tools[toolName];
    if (handler == null) {
      _sendError(request.id, -32601, 'Tool not found: $toolName');
      return;
    }

    try {
      final toolParams = params['arguments'] as Map<String, dynamic>? ?? {};
      final result = await handler(toolParams);

      _sendResponse(request.id, {
        'content': [
          {
            'type': 'text',
            'text': jsonEncode(result),
          }
        ],
      });
    } catch (e, stack) {
      stderr.writeln('Error executing tool $toolName: $e');
      stderr.writeln(stack);
      _sendError(request.id, -32603, 'Tool execution error: $e');
    }
  }

  /// Handle resources list request
  Future<void> _handleResourcesList(MCPRequest request) async {
    final resourcesList = _resources.keys.map((uri) {
      return {
        'uri': uri,
        'name': uri.split('/').last,
        'mimeType': 'application/json',
      };
    }).toList();

    _sendResponse(request.id, {'resources': resourcesList});
  }

  /// Handle resource read request
  Future<void> _handleResourceRead(MCPRequest request) async {
    final params = request.params ?? {};
    final uri = params['uri'] as String?;

    if (uri == null) {
      _sendError(request.id, -32602, 'Resource URI is required');
      return;
    }

    final handler = _resources[uri];
    if (handler == null) {
      _sendError(request.id, -32601, 'Resource not found: $uri');
      return;
    }

    try {
      final result = await handler({});

      _sendResponse(request.id, {
        'contents': [
          {
            'uri': uri,
            'mimeType': 'application/json',
            'text': jsonEncode(result),
          }
        ],
      });
    } catch (e, stack) {
      stderr.writeln('Error reading resource $uri: $e');
      stderr.writeln(stack);
      _sendError(request.id, -32603, 'Resource read error: $e');
    }
  }

  /// Send response
  void _sendResponse(dynamic id, dynamic result) {
    final response = MCPResponse(id: id, result: result);
    _send(response.toJson());
  }

  /// Send error
  void _sendError(dynamic id, int code, String message, [dynamic data]) {
    final response = MCPResponse(
      id: id,
      error: MCPError(code: code, message: message, data: data),
    );
    _send(response.toJson());
  }

  /// Send notification
  void _sendNotification(String method, Map<String, dynamic> params) {
    final notification = MCPNotification(method: method, params: params);
    _send(notification.toJson());
  }

  /// Send JSON message to stdout
  void _send(Map<String, dynamic> message) {
    stdout.writeln(jsonEncode(message));
  }

  /// Get tool info
  MCPToolInfo? getToolInfo(String name) {
    // This would need to be implemented if storing tool info separately
    return null;
  }
}

/// Handler function for MCP tools
typedef MCPToolHandler = Future<dynamic> Function(Map<String, dynamic> params);

/// Handler function for MCP resources
typedef MCPResourceHandler = Future<dynamic> Function(
  Map<String, dynamic> params,
);
