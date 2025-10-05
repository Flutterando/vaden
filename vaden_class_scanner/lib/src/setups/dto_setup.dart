import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden_core/vaden_core.dart';

final _jsonKeyChecker = TypeChecker.fromRuntime(JsonKey);
final useParseChecker = TypeChecker.fromRuntime(UseParse);
final _jsonIgnoreChecker = TypeChecker.fromRuntime(JsonIgnore);

String dtoSetup(ClassElement classElement) {
  final bodyBuffer = StringBuffer();

  if (classElement.isSealed) {
    final unionSetup = _setupUnionType(classElement);
    bodyBuffer.write(unionSetup);
  } else {
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
  }

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
  // Se é tipo built-in suportado
  if (isBuiltInSupported(type)) {
    return _getBuiltInOpenApiSchema(type);
  }

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
    final typeName = type.getDisplayString().replaceAll('?', '');
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
    final paramType = parameter.type.getDisplayString().replaceAll('?', '');
    final isNotNull =
        parameter.type.nullabilitySuffix == NullabilitySuffix.none;
    final hasDefault = parameter.hasDefaultValue;
    var paramValue = '';

    final field = _getFieldByParameter(parameter);

    // Se tem @UseParse(), usa o parser customizado
    if (useParseChecker.hasAnnotationOf(field)) {
      final parser = _getParseFunction(field, isFromJson: true);
      paramValue = "$parser(json['$paramName'])";
    }
    // Se é tipo built-in suportado
    else if (isBuiltInSupported(parameter.type)) {
      paramValue = _getBuiltInDeserializer(
          parameter.type, "json['$paramName']", isNotNull);
    }
    // Se é primitivo ou List/Map de primitivos
    else if (isPrimitiveListOrMap(parameter.type)) {
      if (paramType == 'double') {
        paramValue = "json['$paramName']?.toDouble()";
      } else if (parameter.type.isDartCoreList) {
        final param = parameter.type as ParameterizedType;
        final arg =
            param.typeArguments.first.getDisplayString().replaceAll('?', '');
        paramValue = isNotNull
            ? "json['$paramName'].cast<$arg>()"
            : "json['$paramName'] == null ? null : json['$paramName'].cast<$arg>()";
      } else {
        paramValue = "json['$paramName']";
      }
    } else {
      if (parameter.type.isDartCoreList) {
        final param = parameter.type as ParameterizedType;
        final arg =
            param.typeArguments.first.getDisplayString().replaceAll('?', '');
        paramValue = isNotNull
            ? "fromJsonList<$arg>(json['$paramName'])"
            : "json['$paramName'] == null ? null : fromJsonList<$arg>(json['$paramName'])";
      } else {
        paramValue = isNotNull
            ? "fromJson<$paramType>(json['$paramName'])"
            : "json['$paramName'] == null ? null : fromJson<$paramType>(json['$paramName'])";
      }
    }

    if (parameter.isNamed) {
      if (hasDefault) {
        namedArgsBuffer.writeln(
            "if (json.containsKey('$paramName')) #${parameter.name}: $paramValue,");
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

  throw Exception({'error': 'Parameter is not a field formal parameter'});
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

  // Adiciona runtimeType se a classe implementa uma sealed class
  if (_implementsSealedClass(classElement)) {
    jsonBuffer.writeln("'runtimeType': '${classElement.name}',");
  }

  for (final field in _getAllFields(classElement)) {
    jsonBuffer.writeln(_toJsonField(field));
  }

  return jsonBuffer.toString();
}

String _toJsonField(FieldElement field) {
  final fieldKey = _getFieldName(field);
  final fieldName = field.name;
  final fieldTypeString = field.type.getDisplayString().replaceAll('?', '');
  final isNotNull = field.type.nullabilitySuffix == NullabilitySuffix.none;

  // Se tem @UseParse(), usa o parser customizado (override)
  if (useParseChecker.hasAnnotationOf(field)) {
    final parser = _getParseFunction(field, isFromJson: false);
    return "'$fieldKey': $parser(obj.$fieldName),";
  }

  // Se é tipo built-in suportado, usa serialização automática
  if (isBuiltInSupported(field.type)) {
    final serializer =
        _getBuiltInSerializer(field.type, 'obj.$fieldName', isNotNull);
    return "'$fieldKey': $serializer,";
  }

  // Se é primitivo ou List/Map de primitivos
  else if (isPrimitiveListOrMap(field.type)) {
    return "'$fieldKey': obj.$fieldName,";
  } else {
    if (field.type.isDartCoreList) {
      final param = field.type as ParameterizedType;
      final arg =
          param.typeArguments.first.getDisplayString().replaceAll('?', '');
      return isNotNull
          ? " '$fieldKey': toJsonList<$arg>(obj.$fieldName),"
          : " '$fieldKey': obj.$fieldName == null ? null : toJsonList<$arg>(obj.$fieldName!),";
    } else {
      return isNotNull
          ? "'$fieldKey': toJson<$fieldTypeString>(obj.$fieldName),"
          : "'$fieldKey': obj.$fieldName == null ? null : toJson<$fieldTypeString>(obj.$fieldName!),";
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

String _setupUnionType(ClassElement sealedClass) {
  final buffer = StringBuffer();
  final subtypes = _getUnionSubtypes(sealedClass);

  // FromJson para union type
  buffer.writeln('''
fromJsonMap[${sealedClass.name}] = (Map<String, dynamic> json) {
  final runtimeType = json['runtimeType'] as String?;
  switch (runtimeType) {''');

  for (final subtype in subtypes) {
    buffer.writeln('''
    case '${subtype.name}':
      return fromJson<${subtype.name}>(json);''');
  }

  buffer.writeln('''
    default:
      throw ArgumentError('Unknown runtimeType for ${sealedClass.name}: \$runtimeType');
  }
};''');

  // ToJson para union type - delega baseado no runtimeType do objeto
  buffer.writeln('''
toJsonMap[${sealedClass.name}] = (object) {
  // Obtém o tipo real do objeto em runtime
  final objectType = object.runtimeType;
  switch (objectType) {''');

  for (final subtype in subtypes) {
    buffer.writeln('''
    case ${subtype.name}:
      return toJson<${subtype.name}>(object as ${subtype.name});''');
  }

  buffer.writeln('''
    default:
      throw ArgumentError('Unknown subtype for ${sealedClass.name}: \$objectType');
  }
};''');

  final openApiBody = _toOpenApiUnion(sealedClass, subtypes);
  buffer.writeln('toOpenApiMap[${sealedClass.name}] = $openApiBody;');

  return buffer.toString();
}

List<ClassElement> _getUnionSubtypes(ClassElement sealedClass) {
  final subtypes = <ClassElement>[];

  for (final constructor in sealedClass.constructors) {
    if (constructor.isFactory) {
      final redirectedConstructor = constructor.redirectedConstructor;
      if (redirectedConstructor != null) {
        final targetClass = redirectedConstructor.enclosingElement3;
        if (targetClass is ClassElement) {
          subtypes.add(targetClass);
        }
      }
    }
  }

  return subtypes;
}

String _toOpenApiUnion(ClassElement sealedClass, List<ClassElement> subtypes) {
  final buffer = StringBuffer();

  buffer.writeln('{');
  buffer.writeln('  "oneOf": [');

  bool first = true;
  for (final subtype in subtypes) {
    if (!first) buffer.writeln(',');
    buffer.write('    {r"\$ref": "#/components/schemas/${subtype.name}"}');
    first = false;
  }

  buffer.writeln();
  buffer.writeln('  ],');
  buffer.writeln('  "discriminator": {');
  buffer.writeln('    "propertyName": "runtimeType",');
  buffer.writeln('    "mapping": {');

  first = true;
  for (final subtype in subtypes) {
    if (!first) buffer.writeln(',');
    buffer.write(
        '      "${subtype.name}": "#/components/schemas/${subtype.name}"');
    first = false;
  }

  buffer.writeln();
  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln('}');

  return buffer.toString();
}

bool _implementsSealedClass(ClassElement classElement) {
  // Verifica se alguma das interfaces implementadas é uma sealed class
  for (final interface in classElement.interfaces) {
    final element = interface.element;
    if (element is ClassElement && element.isSealed) {
      return true;
    }
  }

  // Verifica se a superclasse é sealed
  final supertype = classElement.supertype;
  if (supertype != null && !supertype.isDartCoreObject) {
    final element = supertype.element;
    if (element is ClassElement && element.isSealed) {
      return true;
    }
  }

  return false;
}

bool isBuiltInSupported(DartType type) {
  // DateTime
  if (_isDateTime(type)) return true;

  // Enums
  if (type.element is EnumElement) return true;

  // Duration, Uri, etc.
  if (_isDuration(type)) return true;
  if (_isUri(type)) return true;

  return false;
}

bool _isDateTime(DartType type) {
  return type.getDisplayString().replaceAll('?', '') == 'DateTime';
}

bool _isDuration(DartType type) {
  return type.getDisplayString().replaceAll('?', '') == 'Duration';
}

bool _isUri(DartType type) {
  return type.getDisplayString().replaceAll('?', '') == 'Uri';
}

String _getBuiltInSerializer(
    DartType type, String fieldAccess, bool isNotNull) {
  if (_isDateTime(type)) {
    return isNotNull
        ? '$fieldAccess.toIso8601String()'
        : '$fieldAccess?.toIso8601String()';
  }

  if (type.element is EnumElement) {
    return isNotNull ? '$fieldAccess.name' : '$fieldAccess?.name';
  }

  if (_isDuration(type)) {
    return isNotNull
        ? '$fieldAccess.inMilliseconds'
        : '$fieldAccess?.inMilliseconds';
  }

  if (_isUri(type)) {
    return isNotNull ? '$fieldAccess.toString()' : '$fieldAccess?.toString()';
  }

  return fieldAccess;
}

String _getBuiltInDeserializer(
    DartType type, String jsonAccess, bool isNotNull) {
  if (_isDateTime(type)) {
    return isNotNull
        ? 'DateTime.parse($jsonAccess as String)'
        : '$jsonAccess != null ? DateTime.parse($jsonAccess as String) : null';
  }

  if (type.element is EnumElement) {
    final enumName = type.getDisplayString().replaceAll('?', '');
    return isNotNull
        ? '$enumName.values.byName($jsonAccess as String)'
        : '$jsonAccess != null ? $enumName.values.byName($jsonAccess as String) : null';
  }

  if (_isDuration(type)) {
    return isNotNull
        ? 'Duration(milliseconds: $jsonAccess as int)'
        : '$jsonAccess != null ? Duration(milliseconds: $jsonAccess as int) : null';
  }

  if (_isUri(type)) {
    return isNotNull
        ? 'Uri.parse($jsonAccess as String)'
        : '$jsonAccess != null ? Uri.parse($jsonAccess as String) : null';
  }

  return jsonAccess;
}

String _getBuiltInOpenApiSchema(DartType type) {
  if (_isDateTime(type)) {
    return '{"type": "string", "format": "date-time"}';
  }

  if (type.element is EnumElement) {
    final enumElement = type.element as EnumElement;
    final enumValues = enumElement.fields
        .where((field) => field.isEnumConstant)
        .map((field) => '"${field.name}"')
        .join(', ');
    return '{"type": "string", "enum": [$enumValues]}';
  }

  if (_isDuration(type)) {
    return '{"type": "integer", "description": "Duration in milliseconds"}';
  }

  if (_isUri(type)) {
    return '{"type": "string", "format": "uri"}';
  }

  return '{"type": "string"}';
}
