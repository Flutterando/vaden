import 'dart:async';

import 'capability.dart';

class PropertiyType {
  final List<String>? items;
  final PropertiyType? type;
  final String _type;

  PropertiyType.string()
      : items = null,
        type = null,
        _type = 'string';
  PropertiyType.number()
      : items = null,
        type = null,
        _type = 'number';
  PropertiyType.boolean()
      : items = null,
        type = null,
        _type = 'boolean';
  PropertiyType.enums(this.items)
      : type = null,
        _type = 'enum';
  PropertiyType.array(this.type)
      : items = null,
        _type = 'array';

  Map<String, dynamic> toMap() {
    late final Map<String, dynamic> map;
    if (_type == 'enum') {
      map = {'enum': items};
    } else {
      map = {'type': _type};
    }

    if (type != null) {
      map.addAll({'items': type!.toMap()});
    }

    return map;
  }
}

class McpToolAnnotations {
  final String title;
  final bool readOnlyHint;
  final bool destructiveHint;
  final bool idempotentHint;
  final bool openWorldHint;
  McpToolAnnotations({
    required this.title,
    this.readOnlyHint = false,
    this.destructiveHint = true,
    this.idempotentHint = false,
    this.openWorldHint = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'readOnlyHint': readOnlyHint,
      'destructiveHint': destructiveHint,
      'idempotentHint': idempotentHint,
      'openWorldHint': openWorldHint,
    };
  }
}

class McpTool extends Capability {
  final String name;
  final String description;
  final Map<String, PropertiyType>? properties;
  final List<String>? required;
  final McpToolAnnotations? annotations;
  final FutureOr<String> Function(Map<String, dynamic>? arguments) execution;
  McpTool({
    required this.name,
    required this.description,
    this.properties,
    this.required,
    this.annotations,
    required this.execution,
  });

  Future<Map<String, dynamic>> run(Map<String, dynamic>? arguments) async {
    final String responser = await execution(arguments);
    return {
      'content': [
        {'type': "text", 'text': responser}
      ]
    };
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> inputSchema = {'type': "object"};
    if (properties != null) {
      inputSchema.addAll(
          {'properties': properties!.map((k, v) => MapEntry(k, v.toMap()))});
    }
    if (required != null) {
      inputSchema.addAll({'required': required});
    }

    final Map<String, dynamic> map = {
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
    };

    if (annotations != null) {
      map.addAll({'annotations': annotations!.toMap()});
    }

    return map;
  }
}
