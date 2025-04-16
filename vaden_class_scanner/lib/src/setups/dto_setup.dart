import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden/vaden.dart';

final _jsonKeyChecker = TypeChecker.fromRuntime(JsonKey);
final useParseChecker = TypeChecker.fromRuntime(UseParse);
final _jsonIgnoreChecker = TypeChecker.fromRuntime(JsonIgnore);

String dtoSetup(ClassElement classElement) {
  final bodyBuffer = StringBuffer();
  final fromJsonBody = _fromJson(classElement);
  final toJsonBody = _toJson(classElement);
  final toOpenApiBody = _toOpenApi(classElement);

  bodyBuffer.writeln('''
fromJsonMap[${classElement.name}] = (Map<String, dynamic> json) {
  return Function.apply(${classElement.name}.new,
    $fromJsonBody
);
};''');

  bodyBuffer.writeln('''
toJsonMap[${classElement.name}] = (object) {
  final obj = object as ${classElement.name};
  return {
  $toJsonBody
  };
};''');

  bodyBuffer.writeln('toOpenApiMap[${classElement.name}] = $toOpenApiBody;');

  return bodyBuffer.toString();
}

String _toOpenApi(ClassElement classElement) {
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
  buffer.writeln('  "type": "object",');
  buffer.writeln('  "properties": <String, dynamic>{');
  buffer.write(propertiesBuffer.toString());
  buffer.writeln();
  buffer.writeln('  },');
  buffer.writeln('  "required": [${requiredFields.join(', ')}]');
  buffer.writeln('}');
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
    return '{"type": "object", "properties": {"key": {"type": "object",},}}';
  } else if (type.isDartCoreList) {
    final elementType = (type as ParameterizedType).typeArguments.first;
    final elementSchema = _fieldToSchema(elementType);

    return '{"type": "array", "items": $elementSchema}';
  } else {
    final typeName = type.getDisplayString();
    return '{r"\$ref": "#/components/schemas/$typeName"}';
  }
}

String _fromJson(ClassElement classElement) {
  final positionalArgsBuffer = StringBuffer();
  final namedArgsBuffer = StringBuffer();

  final constructor = classElement.constructors.firstWhere(
    (ctor) => !ctor.isFactory && ctor.isPublic,
  );

  for (final parameter in constructor.parameters) {
    final paramName = _getParameterName(parameter);
    final paramType = parameter.type.getDisplayString();
    final isNotNull = parameter.type.nullabilitySuffix == NullabilitySuffix.none;
    final hasDefault = parameter.hasDefaultValue;
    var paramValue = '';

    final field = _getFieldByParameter(parameter);

    if (useParseChecker.hasAnnotationOf(field)) {
      final parser = _getParseFunction(field, isFromJson: true);
      paramValue = "$parser(json['$paramName'])";
    } else if (isPrimitiveListOrMap(parameter.type)) {
      if (paramType == 'double') {
        paramValue = "json['$paramName']?.toDouble()";
      } else if (parameter.type.isDartCoreList) {
        final param = parameter.type as ParameterizedType;
        final arg = param.typeArguments.first.getDisplayString();
        paramValue = isNotNull
            ? "json['$paramName'].cast<$arg>()"
            : "json['$paramName'] == null ? null : json['$paramName'].cast<$arg>()";
      } else {
        paramValue = "json['$paramName']";
      }
    } else {
      if (parameter.type.isDartCoreList) {
        final param = parameter.type as ParameterizedType;
        final arg = param.typeArguments.first.getDisplayString();
        paramValue = isNotNull ? "fromJsonList<$arg>(json['$paramName'])" : "json['$paramName'] == null ? null : fromJsonList<$arg>(json['$paramName'])";
      } else {
        paramValue = isNotNull ? "fromJson<$paramType>(json['$paramName'])" : "json['$paramName'] == null ? null : fromJson<$paramType>(json['$paramName'])";
      }
    }

    if (parameter.isNamed) {
      if (hasDefault) {
        namedArgsBuffer.writeln("if (json.containsKey('$paramName')) #${parameter.name}: $paramValue,");
      } else {
        namedArgsBuffer.writeln("#${parameter.name}: $paramValue,");
      }
    } else {
      positionalArgsBuffer.writeln("    $paramValue,");
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('[');
  buffer.write(positionalArgsBuffer.toString());
  buffer.writeln('],');
  buffer.writeln('{');
  buffer.write(namedArgsBuffer.toString());
  buffer.writeln('}');

  return buffer.toString();
}

FieldElement _getFieldByParameter(ParameterElement parameter) {
  if (parameter.isInitializingFormal) {
    final ctorParam = parameter as FieldFormalParameterElement;
    return ctorParam.field!;
  }

  if (parameter is FieldFormalParameterElement) {
    return parameter.field!;
  }

  if (parameter is SuperFormalParameterElement) {
    final superParam = parameter.superConstructorParameter!;

    if (superParam is FieldFormalParameterElement) {
      return superParam.field!;
    }
  }

  throw ResponseException.internalServerError({'error': 'Parameter is not a field formal parameter'});
}

String _getParseFunction(FieldElement field, {required bool isFromJson}) {
  final annotation = useParseChecker.firstAnnotationOf(field);
  if (annotation == null) return '';

  final parserType = annotation.getField('parser')?.toTypeValue();
  if (parserType == null) return '';

  final parserName = parserType.getDisplayString();
  return isFromJson ? '$parserName().fromJson' : '$parserName().toJson';
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

String _getParameterName(ParameterElement parameter) {
  if (parameter.isInitializingFormal) {
    final ctorParam = parameter as FieldFormalParameterElement;
    final fieldElement = ctorParam.field!;
    return _getFieldName(fieldElement);
  }

  return parameter.name;
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

String _toJson(ClassElement classElement) {
  final jsonBuffer = StringBuffer();
  for (final field in _getAllFields(classElement)) {
    jsonBuffer.writeln(_toJsonField(field));
  }

  return jsonBuffer.toString();
}

String _toJsonField(FieldElement field) {
  final fieldKey = _getFieldName(field);
  final fieldName = field.name;
  final fieldTypeString = field.type.getDisplayString();
  final isNotNull = field.type.nullabilitySuffix == NullabilitySuffix.none;

  if (useParseChecker.hasAnnotationOf(field)) {
    final parser = _getParseFunction(field, isFromJson: false);
    return "'$fieldKey': $parser(obj.$fieldName),";
  } else if (isPrimitiveListOrMap(field.type)) {
    return "'$fieldKey': obj.$fieldName,";
  } else {
    if (field.type.isDartCoreList) {
      final param = field.type as ParameterizedType;
      final arg = param.typeArguments.first;
      return isNotNull ? " '$fieldKey': toJsonList<$arg>(obj.$fieldName)," : " '$fieldKey': obj.$fieldName == null ? null : toJsonList<$arg>(obj.$fieldName!),";
    } else {
      return isNotNull ? "'$fieldKey': toJson<$fieldTypeString>(obj.$fieldName)," : "'$fieldKey': obj.$fieldName == null ? null : toJson<$fieldTypeString>(obj.$fieldName!),";
    }
  }
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

bool isPrimitive(DartType type) {
  return type.isDartCoreInt || //
      type.isDartCoreDouble ||
      type.isDartCoreBool ||
      type.isDartCoreMap ||
      type.isDartCoreString;
}

bool isPrimitiveListOrMap(DartType type) {
  if (type.isDartCoreList) {
    final param = type as ParameterizedType;
    final arg = param.typeArguments.first;

    return isPrimitive(arg);
  }
  if (type.isDartCoreMap) {
    return true;
  }
  return isPrimitive(type);
}
