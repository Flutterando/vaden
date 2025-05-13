import 'dart:async';

import 'package:dart_mcp/client.dart';
import 'package:vaden/vaden.dart' as vaden;

class McpTool {
  final Tool tool;
  final FutureOr<CallToolResult> Function(CallToolRequest request) impl;

  McpTool._({required this.tool, required this.impl});

  factory McpTool.fromMap(Map<String, dynamic> map,
      {required vaden.AutoInjector injector}) {
    final tool = Tool(
        name: map['name'],
        description: map['description'],
        annotations: ToolAnnotations(
          title: map['title'],
          readOnlyHint: map['readOnlyHint'],
          destructiveHint: map['destructiveHint'],
          idempotentHint: map['idempotentHint'],
          openWorldHint: map['openWorldHint'],
        ),
        inputSchema: _inputSchema(map, injector: injector));
    return McpTool._(
      tool: tool,
      impl: (request) async {
        try {
          final String content =
              await map['function'](request.arguments, injector);
          return CallToolResult(content: [Content.text(text: content)]);
        } catch (e) {
          return CallToolResult(
              content: [Content.text(text: e.toString())], isError: true);
        }
      },
    );
  }

  static ObjectSchema _inputSchema(Map<String, dynamic> map,
      {required vaden.AutoInjector injector}) {
    Map<String, Schema>? properties;
    List<String>? required;

    if (map['properties'] is Map<String, dynamic>) {
      (properties, required) = _parametersFromMap(map, injector: injector);
    }

    return ObjectSchema(
      title: map['title'],
      description: map['description'],
      properties: properties,
      required: required,
    );
  }

  static (Map<String, Schema>?, List<String>?) _parametersFromMap(
      Map<String, dynamic> map,
      {required vaden.AutoInjector injector}) {
    final propertiesMap = map['properties'] as Map<String, dynamic>;

    if (propertiesMap.values.first['type'] == 'dto') {
      return _dtoProperties(propertiesMap.values.first['items'],
          injector: injector);
    }

    return (
      propertiesMap.map((k, v) => MapEntry(k, _schemaFromMap(v, injector))),
      map['required']
    );
  }

  static (Map<String, Schema>?, List<String>?) _dtoProperties(Type dto,
      {required vaden.AutoInjector injector}) {
    final vaden.MCP mcp = injector.get<vaden.MCP>();
    final propertiesMap = mcp.toProperties(dto);

    if (propertiesMap == null) return (null, null);

    _selfReference(propertiesMap, dto);

    Map<String, Schema> properties =
        (propertiesMap['items'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, _schemaFromMap(v, injector)));
    List<String> required = propertiesMap['required'];

    return (properties, required);
  }

  static void _selfReference(Map<String, dynamic> propertiesMap, Type dto) {
    if (propertiesMap['type'] == 'list') {
      _selfReference(propertiesMap['items'], dto);
    }
    if (propertiesMap['type'] == 'array') {
      final itens = propertiesMap['items'] as Map<String, dynamic>;
      itens.values.forEach((map) => _selfReference(map, dto));
    }
    if (propertiesMap['type'] == 'dto' && propertiesMap['items'] == dto) {
      throw Exception('MCP-DTO Error: Self-reference is not allowed');
    }
  }

  static Schema _schemaFromMap(
      Map<String, dynamic> map, vaden.AutoInjector injector) {
    if (map['type'] == 'list') {
      return Schema.list(items: _schemaFromMap(map['items'], injector));
    }
    if (map['type'] == 'array') {
      return Schema.object(
        properties: map['items']
            .map((k, v) => MapEntry(k, _schemaFromMap(v, injector))),
        required: map['required'],
      );
    }
    if (map['type'] == 'dto') {
      final (properties, required) =
          _dtoProperties(map['items'], injector: injector);
      return Schema.object(properties: properties, required: required);
    }
    return switch (map['type']) {
      'string' => Schema.string(),
      'integer' => Schema.int(),
      'boolean' => Schema.bool(),
      'number' => Schema.num(),
      _ => Schema.nil(),
    };
  }
}
