import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden_core/vaden_core.dart';

final controllerChecker = TypeChecker.fromRuntime(Controller);

// documentation
final apiChecker = TypeChecker.fromRuntime(Api);
final apiOperationChecker = TypeChecker.fromRuntime(ApiOperation);
final apiResponseChecker = TypeChecker.fromRuntime(ApiResponse);
final apiContentChecker = TypeChecker.fromRuntime(ApiContent);
final apiParamChecker = TypeChecker.fromRuntime(ApiParam);
final apiQueryChecker = TypeChecker.fromRuntime(ApiQuery);
final apiSecurityChecker = TypeChecker.fromRuntime(ApiSecurity);

final methodCheckers = <(TypeChecker, String)>[
  (TypeChecker.fromRuntime(Get), 'get'),
  (TypeChecker.fromRuntime(Post), 'post'),
  (TypeChecker.fromRuntime(Put), 'put'),
  (TypeChecker.fromRuntime(Patch), 'patch'),
  (TypeChecker.fromRuntime(Delete), 'delete'),
  (TypeChecker.fromRuntime(Head), 'head'),
  (TypeChecker.fromRuntime(Options), 'options'),
  (TypeChecker.fromRuntime(Mount), 'mount'),
];

final useGuardsChecker = TypeChecker.fromRuntime(UseGuards);
final useMiddlewareChecker = TypeChecker.fromRuntime(UseMiddleware);

final paramChecker = TypeChecker.fromRuntime(Param);
final queryChecker = TypeChecker.fromRuntime(Query);
final headerChecker = TypeChecker.fromRuntime(Header);
final contextChecker = TypeChecker.fromRuntime(Context);
final bodyChecker = TypeChecker.fromRuntime(Body);

String controllerSetup(ClassElement classElement) {
  final bodyBuffer = StringBuffer();

  String wrapMiddleware(String middlewareTypeName) {
    return """
(Handler inner) {
  return (Request request) async {
    final guard = _injector.get<$middlewareTypeName>();
    return await guard.handler(request, inner);
  };
}""";
  }

  final controllerAnn = controllerChecker.firstAnnotationOf(classElement);
  if (controllerAnn == null) return '';

  final controllerPath = controllerAnn.getField('path')?.toStringValue() ?? '';

  final controllerName = classElement.name;

  final controllerApi = apiChecker.firstAnnotationOf(classElement);
  Api? api;
  if (controllerApi != null) {
    final tag = controllerApi.getField('tag')?.toStringValue() ?? '';
    final description =
        controllerApi.getField('description')?.toStringValue() ?? '';
    api = Api(tag: tag, description: description);
    bodyBuffer.writeln(
        "apis.add(const Api(tag: '${api.tag}', description: '${api.description}'));");
  }

  final controllerApiSecurityAnnotation =
      apiSecurityChecker.firstAnnotationOf(classElement);
  ApiSecurity? globalApiSecurity;

  if (controllerApiSecurityAnnotation != null) {
    final securitySchemes =
        controllerApiSecurityAnnotation.getField('schemes')?.toListValue() ??
            [];
    final securityList =
        securitySchemes.map((e) => e.toStringValue()!).toList();
    globalApiSecurity = ApiSecurity(securityList);
  }

  final classGuards = useGuardsChecker.firstAnnotationOf(classElement);
  final classMidds = useMiddlewareChecker.firstAnnotationOf(classElement);

  final routerVar = "router$controllerName";
  bodyBuffer.writeln("final $routerVar = Router();");

  for (final method in _getAllMethods(classElement)) {
    if (method.enclosingElement3.name == 'Object') continue;
    if (method.isStatic) continue;
    if (method.isPrivate) continue;
    if (method.name == 'noSuchMethod') continue;
    if (method.name == 'toString') continue;
    if (method.name == 'hashCode') continue;
    if (method.name == '==') continue;
    if (method.name == 'runtimeType') continue;

    String? routerMethod;
    String? routePath;

    for (final (checker, shelfMethod) in methodCheckers) {
      final httpAnn = checker.firstAnnotationOf(method);
      if (httpAnn != null) {
        routerMethod = shelfMethod;
        routePath = httpAnn.getField('path')?.toStringValue() ?? '/';
        break;
      }
    }
    if (routerMethod == null) continue;

    final apiPathResolver = '$controllerPath$routePath'
        .replaceAll('<', '{')
        .replaceAll('>', '}')
        .replaceAll('//', '/');

    if (api != null && routerMethod != 'mount') {
      final convertSecurity =
          globalApiSecurity?.schemes.map((e) => "{'$e': []}").toList();
      final security = convertSecurity != null
          ? '[$convertSecurity]'
          : '<Map<String, dynamic>>[]';

      bodyBuffer.writeln("""
paths['$apiPathResolver'] = <String, dynamic>{
  ...paths['$apiPathResolver'] ?? <String, dynamic>{},
  '$routerMethod': {
    'tags': ['${api.tag}'],
    'summary': '',
    'description': '',
    'responses': <String, dynamic>{},
    'parameters': <Map<String, dynamic>>[],
    'security': $security,
  },

};

""");

      final apiSecurityAnnotation =
          apiSecurityChecker.firstAnnotationOf(method);
      if (apiSecurityAnnotation != null) {
        final securitySchemes =
            apiSecurityAnnotation.getField('schemes')?.toListValue() ?? [];
        final securityList =
            securitySchemes.map((e) => "{'${e.toStringValue()}': []}").toList();
        bodyBuffer.writeln(
            "paths['$apiPathResolver']['$routerMethod']['security'] = $securityList;");
      }

      final apiOperationAnnotation =
          apiOperationChecker.firstAnnotationOf(method);

      if (apiOperationAnnotation != null) {
        final summary =
            apiOperationAnnotation.getField('summary')?.toStringValue() ?? '';
        final description =
            apiOperationAnnotation.getField('description')?.toStringValue() ??
                '';
        bodyBuffer.writeln(
            "paths['$apiPathResolver']['$routerMethod']['summary'] = '$summary';");
        bodyBuffer.writeln(
            "paths['$apiPathResolver']['$routerMethod']['description'] = '$description';");
      }

      final apiResponseAnnotations = apiResponseChecker.annotationsOf(method);

      for (final apiResponseAnnotation in apiResponseAnnotations) {
        final statusCode =
            apiResponseAnnotation.getField('statusCode')?.toIntValue() ?? 200;
        final description =
            apiResponseAnnotation.getField('description')?.toStringValue() ??
                '';

        bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['responses']['$statusCode'] = {
  'description': '$description',
  'content': <String, dynamic>{},
};
""");
        final content = apiResponseAnnotation.getField('content');
        if (content != null && !content.isNull) {
          final type = content.getField('type')!.toStringValue();

          bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['responses']['$statusCode']['content']['$type'] = <String, dynamic>{};
""");

          final schema = content.getField('schema')?.toTypeValue();

          if (schema != null) {
            if (schema.isDartCoreList) {
              final schemaName = _extractListElementType(schema, classElement)
                  .getDisplayString()
                  .replaceAll('?', '');
              bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['responses']['$statusCode']['content']['$type']['schema'] = {
    'type': 'array',
    'items': {
      '\\\$ref': '#/components/schemas/$schemaName',
    },
};
""");
            } else {
              final schemaName = schema.getDisplayString().replaceAll('?', '');
              bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['responses']['$statusCode']['content']['$type']['schema'] = {
  '\\\$ref': '#/components/schemas/$schemaName',
};
""");
            }
          }
        }
      }
    }

    final pipelineVar = "pipeline$controllerName${method.name}";
    bodyBuffer.writeln("var $pipelineVar = const Pipeline();");

    if (classGuards != null) {
      final guardList = classGuards.getField('guards')?.toListValue() ?? [];
      for (final g in guardList) {
        final guardTypeName = g.toTypeValue()?.getDisplayString();
        if (guardTypeName != null) {
          bodyBuffer.writeln(
              "$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(guardTypeName)});");
        }
      }
    }
    if (classMidds != null) {
      final middList = classMidds.getField('middlewares')?.toListValue() ?? [];
      for (final m in middList) {
        final middTypeName = m.toTypeValue()?.getDisplayString();
        if (middTypeName != null) {
          bodyBuffer.writeln(
              "$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(middTypeName)});");
        }
      }
    }

    final methodGuards = useGuardsChecker.firstAnnotationOf(method);
    final methodMidds = useMiddlewareChecker.firstAnnotationOf(method);
    if (methodGuards != null) {
      final guardList = methodGuards.getField('guards')?.toListValue() ?? [];
      for (final g in guardList) {
        final guardTypeName = g.toTypeValue()?.getDisplayString();
        if (guardTypeName != null) {
          bodyBuffer.writeln(
              "$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(guardTypeName)});");
        }
      }
    }
    if (methodMidds != null) {
      final middList = methodMidds.getField('middlewares')?.toListValue() ?? [];
      for (final m in middList) {
        final middTypeName = m.toTypeValue()?.getDisplayString();
        if (middTypeName != null) {
          bodyBuffer.writeln(
              "$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(middTypeName)});");
        }
      }
    }

    final paramCodeList = <String>[];
    for (final parameter in method.parameters) {
      if (bodyChecker.hasAnnotationOf(parameter)) {
        final resolvedType =
            _resolveTypeFromGeneric(parameter.type, classElement);
        final typeName = resolvedType.getDisplayString().replaceAll('?', '');
        final isListType = resolvedType.isDartCoreList;

        if (api != null) {
          if (isListType) {
            final elementType =
                _extractListElementType(resolvedType, classElement);
            final elementTypeName =
                elementType.getDisplayString().replaceAll('?', '');
            bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['requestBody'] = {
  'content': {
    'application/json': {
      'schema': {
        'type': 'array',
        'items': {
          '\\\$ref': '#/components/schemas/$elementTypeName',
        },
      },
    },
  },
  'required': true,
};
""");
          } else {
            bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['requestBody'] = {
  'content': {
    'application/json': {
      'schema': {
        '\\\$ref': '#/components/schemas/$typeName',
      },
    },
  },
  'required': true,
};
""");
          }
        }

        if (isListType) {
          final elementType =
              _extractListElementType(resolvedType, classElement);
          final elementTypeName = elementType.getDisplayString();
          paramCodeList.add("""
final bodyString = await request.readAsString();
final bodyJson = jsonDecode(bodyString) as List;
final ${parameter.name} =  _injector.get<DSON>().fromJsonList<$elementTypeName>(bodyJson) as dynamic;

if (${parameter.name} == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid body: ($typeName)'}),
        );
}
""");
        } else {
          paramCodeList.add("""
final bodyString = await request.readAsString();
final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
final ${parameter.name} =  _injector.get<DSON>().fromJson<$typeName>(bodyJson) as dynamic;

if (${parameter.name} == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'Invalid body: ($typeName)'}),
        );
}

if (${parameter.name} is Validator<$typeName>) {
  final validator = ${parameter.name}.validate(ValidatorBuilder<$typeName>());
  final resultValidator = validator.validate(${parameter.name}  as $typeName);
  if (!resultValidator.isValid) {
    throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
  }
}
""");
        }
      } else if (paramChecker.hasAnnotationOf(parameter)) {
        final pname = paramChecker
                .firstAnnotationOf(parameter)
                ?.getField('name')
                ?.toStringValue() ??
            parameter.name;
        final isNotNull = !_isNullable(parameter.type);

        if (api != null) {
          bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['parameters']?.add({
  'name': '$pname',
  'in': 'path',
  'required': $isNotNull,
  'schema': {
    'type': 'string',
  },
});
""");
        }

        if (isNotNull) {
          paramCodeList.add("""
  if (request.params['$pname'] == null) {
    return Response(400, body: jsonEncode({'error': 'Path Param is required ($pname)'}));
  }
  final ${parameter.name} =  _parse<${parameter.type.getDisplayString(withNullability: false)}>(request.params['$pname'])!;

""");
        } else {
          paramCodeList.add(
              "final ${parameter.name} =  _parse<${parameter.type.getDisplayString(withNullability: false)}>(request.params['$pname']);");
        }
      } else if (queryChecker.hasAnnotationOf(parameter)) {
        final qname = queryChecker
                .firstAnnotationOf(parameter)
                ?.getField('name')
                ?.toStringValue() ??
            parameter.name;
        final isNotNull = !_isNullable(parameter.type);

        if (api != null) {
          bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['parameters']?.add({
  'name': '$qname',
  'in': 'query',
  'required': $isNotNull,
  'schema': {
    'type': 'string',
  },
});
""");
        }
        if (isNotNull) {
          paramCodeList.add("""
  if (request.url.queryParameters['$qname'] == null) {
    return Response(400, body: jsonEncode({'error': 'Query param is required ($qname)'}));
  }
  final ${parameter.name} = _parse<${parameter.type.getDisplayString(withNullability: false)}>(request.url.queryParameters['$qname'])!;

""");
        } else {
          paramCodeList.add(
              "final ${parameter.name} = _parse<${parameter.type.getDisplayString(withNullability: false)}>(request.url.queryParameters['$qname']);");
        }
      } else if (headerChecker.hasAnnotationOf(parameter)) {
        final hname = headerChecker
                .firstAnnotationOf(parameter)
                ?.getField('name')
                ?.toStringValue() ??
            parameter.name;
        final isNotNull = !_isNullable(parameter.type);

        if (isNotNull) {
          paramCodeList.add("""
  if (request.headers['$hname'] == null) {
    return Response(400, body: jsonEncode({'error': 'Header is required ($hname)'}));
  }
  final ${parameter.name} = _parse<${parameter.type.getDisplayString(withNullability: false)}>(request.headers['$hname'])!;

""");
        } else {
          paramCodeList.add(
              "final ${parameter.name} = _parse<${parameter.type.getDisplayString(withNullability: false)}>(request.headers['$hname']);");
        }
      } else if (contextChecker.hasAnnotationOf(parameter)) {
        final cname = contextChecker
                .firstAnnotationOf(parameter)
                ?.getField('name')
                ?.toStringValue() ??
            parameter.name;
        final isNotNull = !_isNullable(parameter.type);

        if (isNotNull) {
          paramCodeList.add("""
  if (request.context['$cname'] == null) {
    return Response(400, body: jsonEncode({'error': 'Context is required ($cname)'}));
  }
""");
        }
        paramCodeList.add(
            "final ${parameter.name} = request.context['$cname'] as dynamic;");
      } else {
        final paramType = parameter.type.getDisplayString();
        if (paramType == 'Request' || paramType == 'Request?') {
          if (parameter.name != 'request') {
            paramCodeList.add("final ${parameter.name} = request;");
          }
        }
      }
    }

    final handlerVar = "handler$controllerName${method.name}";
    bodyBuffer.writeln("final $handlerVar = (Request request) async {");
    for (final code in paramCodeList) {
      bodyBuffer.writeln("  $code");
    }
    final callParams = method.parameters.map((p) => p.name).join(', ');
    final isFuture = method.returnType.isDartAsyncFuture ||
        method.returnType.isDartAsyncFutureOr;
    final returnType = _getUnderlyingType(method.returnType, classElement);

    bodyBuffer.writeln("final ctrl = _injector.get<$controllerName>();");

    final display = returnType.getDisplayString();

    if (display == 'Response') {
      bodyBuffer.writeln("""
  final result = ${isFuture ? 'await' : ''} ctrl.${method.name}($callParams);
  return result;
""");
    } else if (display.startsWith('ResponseEntity')) {
      bodyBuffer.writeln("""
  final result = ${isFuture ? 'await' : ''} ctrl.${method.name}($callParams);
  return result.generateResponse(_injector.get<DSON>());
""");
    } else {
      late final String toJsonResponse;
      if (display == 'String') {
        toJsonResponse = """
          return Response.ok(result, headers: {'Content-Type': 'text/plain'});
          """;
      } else if (display == 'List<int>') {
        toJsonResponse = """
          return Response.ok(result, headers: {'Content-Type': 'application/octet-stream'});
          """;
      } else if ([
        'Map<String, dynamic>',
        'Map<String, Object>',
        'Map<String, String>',
        'List<Map<String, dynamic>>',
        'List<Map<String, Object>>',
        'List<Map<String, String>>',
      ].contains(display)) {
        toJsonResponse = """
          return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
          """;
      } else {
        if (returnType.isDartCoreList) {
          final elementType = _extractListElementType(returnType, classElement);
          toJsonResponse = """
          final jsoResponse = _injector.get<DSON>().toJsonList<${elementType.getDisplayString()}>(result);
          return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
          """;
        } else {
          toJsonResponse = """
          final jsoResponse = _injector.get<DSON>().toJson<$display>(result);
          return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
          """;
        }
      }

      bodyBuffer.writeln("""
   final result = ${isFuture ? 'await' : ''} ctrl.${method.name}($callParams);
  $toJsonResponse
 

""");
    }

    bodyBuffer.writeln("};");

    bodyBuffer.writeln(
        "$routerVar.$routerMethod('$routePath', $pipelineVar.addHandler($handlerVar));");

    // documetation
  }

  // Concatena o router do controller com o router global
  bodyBuffer.writeln("_router.mount('$controllerPath', $routerVar.call);");

  return bodyBuffer.toString();
}

DartType _extractListElementType(DartType type, ClassElement currentClass) {
  if (type is ParameterizedType &&
      type.isDartCoreList &&
      type.typeArguments.isNotEmpty) {
    return _resolveTypeFromGeneric(type.typeArguments.first, currentClass);
  }
  throw Exception('Expected a list type');
}

bool _isNullable(DartType type) {
  return type.nullabilitySuffix != NullabilitySuffix.none;
}

DartType _getUnderlyingType(DartType type, ClassElement currentClass) {
  if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
    final futureType = type as ParameterizedType;
    final typeArguments = futureType.typeArguments;

    if (typeArguments.isNotEmpty) {
      return _resolveTypeFromGeneric(typeArguments.first, currentClass);
    }
  }

  return _resolveTypeFromGeneric(type, currentClass);
}

DartType _resolveTypeFromGeneric(DartType type, ClassElement currentClass) {
  final thisType = currentClass.thisType;

  final superclass = thisType.element.supertype;
  if (superclass == null) return type;

  if (superclass.element.typeParameters.isEmpty) return type;

  final typeArguments = superclass.typeArguments;
  final typeParams = superclass.element.typeParameters;

  final typeMap = <String, DartType>{
    for (int i = 0; i < typeParams.length; i++)
      typeParams[i].name: typeArguments[i],
  };

  if (type is TypeParameterType && typeMap.containsKey(type.element.name)) {
    return typeMap[type.element.name]!;
  }

  return type;
}

List<MethodElement> _getAllMethods(ClassElement classElement) {
  final allMethods = <String, MethodElement>{};

  for (final m in classElement.methods) {
    allMethods[m.name] = m;
  }

  for (final supertype in classElement.allSupertypes) {
    if (supertype.element.name == 'Object') continue;

    for (final method in supertype.element.methods) {
      allMethods.putIfAbsent(method.name, () => method);
    }
  }

  return allMethods.values.toList();
}
