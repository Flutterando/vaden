import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden/vaden.dart';

final _toolChecker = TypeChecker.fromRuntime(Tool);

final _jsonKeyChecker = TypeChecker.fromRuntime(JsonKey);
final useParseChecker = TypeChecker.fromRuntime(UseParse);
final _jsonIgnoreChecker = TypeChecker.fromRuntime(JsonIgnore);

String mcpDtoPropertiesSetup(ClassElement classElement) {
  final toPropertiesBody = _toProperties(classElement);
  return '''
      toPropertiesMap[${classElement.name}] = $toPropertiesBody;
      ''';
}

String mcpControllerSetup(ClassElement classElement) {
  final bodyBuffer = StringBuffer();

  final toolMaps = _toolsMap(classElement);
  for (var map in toolMaps) {
    bodyBuffer.writeln('toolList.add($map);');
    bodyBuffer.writeln();
  }

  return bodyBuffer.toString();
}

String _toProperties(ClassElement classElement) {
  final propertiesBuffer = StringBuffer();
  final requiredFields = <String>[];

  final fields = _getAllFields(classElement);

  bool first = true;
  for (final field in fields) {
    final fieldName = _getFieldName(field);
    var schema = '';
    if (useParseChecker.hasAnnotationOf(field)) {
      final parser = _getParseConverteType(field);
      schema = _fieldToSchema(parser);
    } else {
      schema = _fieldToSchema(field.type);
    }
    if (!first) propertiesBuffer.writeln(',');
    propertiesBuffer.write('    "$fieldName": $schema');
    first = false;

    if (field.type.nullabilitySuffix == NullabilitySuffix.none) {
      requiredFields.add('"$fieldName"');
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('{');
  buffer.writeln('  "type": "array",');
  buffer.writeln('  "items": <String, dynamic>{');
  buffer.write(propertiesBuffer.toString());
  buffer.writeln();
  buffer.writeln('  },');
  buffer.writeln('  "required": [${requiredFields.join(', ')}]');
  buffer.writeln('}');
  return buffer.toString();
}

List<String> _toolsMap(ClassElement classElement) {
  final tools = <String>[];
  for (var method in classElement.methods) {
    final toolAnn = _toolChecker.firstAnnotationOf(method);
    if (toolAnn == null) continue;
    final annotations = _annotationToBuffer(toolAnn);
    final properties = _propertiesToBuffer(method);
    final function = _functionToBuffer(method, classElement);

    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln(
        '  "name": "${classElement.name.toLowerCase()}_${method.name.toSnakeCase()}",');
    buffer.write(annotations);
    if (properties.isNotEmpty) buffer.write(properties);
    buffer.write(function);
    buffer.writeln('}');
    tools.add(buffer.toString());
  }

  return tools;
}

String _annotationToBuffer(DartObject toolAnn) {
  final getters = <String, Object? Function()>{
    'description': () => toolAnn.getField('description')?.toStringValue() ?? '',
    'title': () => toolAnn.getField('title')?.toStringValue(),
    'readOnlyHint': () => toolAnn.getField('readOnlyHint')?.toBoolValue(),
    'destructiveHint': () => toolAnn.getField('destructiveHint')?.toBoolValue(),
    'idempotentHint': () => toolAnn.getField('idempotentHint')?.toBoolValue(),
    'openWorldHint': () => toolAnn.getField('openWorldHint')?.toBoolValue(),
  };
  String literal(Object? v) {
    if (v is String) return "'${v.replaceAll("'", r"\'")}'";
    if (v is bool || v is num) return v.toString();
    return 'null';
  }

  final buffer = StringBuffer();
  getters.forEach((key, getter) {
    final value = getter();
    if (value != null) {
      buffer.writeln('"$key": ${literal(value)},');
    }
  });

  return buffer.toString();
}

String _propertiesToBuffer(MethodElement method) {
  if (method.parameters.isEmpty) return '';

  final param = method.parameters.first;

  final buffer = StringBuffer();
  buffer.writeln('"properties": <String, dynamic>{');
  buffer.writeln('  "${param.name}": ${_fieldToSchema(param.type)}');
  buffer.writeln('},');
  if (param.isRequired) buffer.writeln('  "required": ["${param.name}"],');
  return buffer.toString();
}

String _fieldToSchema(DartType type) {
  if (type.isDartCoreInt) {
    return '{"type": "integer"}';
  } else if (type.isDartCoreDouble) {
    return '{"type": "number"}';
  } else if (type.isDartCoreBool) {
    return '{"type": "boolean"}';
  } else if (type.isDartCoreString) {
    return '{"type": "string"}';
  } else if (type.isDartCoreMap) {
    return '{"type": "array"}';
  } else if (type.isDartCoreList) {
    final elementType = (type as ParameterizedType).typeArguments.first;
    final elementSchema = _fieldToSchema(elementType);

    return '{"type": "list", "items": $elementSchema}';
  } else {
    return '{"type": "dto", "items": ${type.name}}';
  }
}

String _functionToBuffer(MethodElement method, ClassElement classElement) {
  final className = classElement.name;
  final methodName = method.name;

  final param = method.parameters.isNotEmpty ? method.parameters.first : null;

  String arg = '';
  if (param != null && isPrimitive(param.type)) {
    arg =
        'final arg = arguments!.values.first as ${param.type.getDisplayString(withNullability: true)};';
  }
  if (param != null && !isPrimitive(param.type)) {
    arg =
        'final arg = injector.get<DSON>().fromJson<${param.type.name}>(arguments as Map<String, dynamic>);';
  }

  final awaitRT = method.isAsynchronous ? ' await' : '';
  final argRT = param != null ? ' arg' : '';

  final buffer = StringBuffer();
  buffer.writeln(
      '"function": (Map<String, Object?>? arguments, AutoInjector injector) async {');
  buffer.writeln('  final mcpController = injector.get<$className>();');
  if (arg.isNotEmpty) buffer.writeln('  $arg');
  buffer.writeln('  return$awaitRT mcpController.$methodName($argRT);');
  buffer.writeln('},');
  return buffer.toString();
}

List<FieldElement> _getAllFields(ClassElement classElement) {
  final fields = <FieldElement>[];

  ClassElement? current = classElement;

  while (current != null) {
    fields.addAll(current.fields.where((f) => !f.isSynthetic));
    final superType = current.supertype;
    if (superType == null || superType.isDartCoreObject) break;

    current = superType.element as ClassElement?;
  }

  return fields.where((f) {
    if (_jsonIgnoreChecker.hasAnnotationOf(f)) {
      return false;
    }
    return !f.isStatic && !f.isPrivate;
  }).toList();
}

String _getFieldName(FieldElement parameter) {
  if (_jsonKeyChecker.hasAnnotationOfExact(parameter)) {
    final annotation = _jsonKeyChecker.firstAnnotationOfExact(parameter);
    final name = annotation?.getField('name')?.toStringValue();
    if (name != null) {
      return name;
    }
  }

  return parameter.name;
}

DartType _getParseConverteType(FieldElement field) {
  final annotation = useParseChecker.firstAnnotationOf(field)!;

  final parserType = annotation.getField('parser')!.toTypeValue();

  return getParseReturnType(parserType as InterfaceType)!;
}

DartType? getParseReturnType(InterfaceType parserType) {
  final paramParseChecker = TypeChecker.fromRuntime(ParamParse);

  for (var type in parserType.allSupertypes) {
    if (!paramParseChecker.isExactlyType(type)) {
      continue;
    }

    final typeArgs = type.typeArguments;
    if (typeArgs.length == 2) {
      return typeArgs[1];
    }
  }
  return null;
}

bool isPrimitive(DartType type) {
  return type.isDartCoreInt || //
      type.isDartCoreDouble ||
      type.isDartCoreBool ||
      type.isDartCoreList ||
      type.isDartCoreString;
}

extension _CamelCaseToSnakeCase on String {
  String toSnakeCase() {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final char = this[i];
      if (char == char.toUpperCase() && char != '_') {
        if (i != 0) {
          buffer.write('_');
        }
        buffer.write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
