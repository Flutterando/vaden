import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:vaden/vaden.dart';

import 'setups/dto_setup.dart';

class AggregatingVadenBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$package$': ['lib/vaden_application.dart']
  };

  AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', 'vaden_application.dart'),
    );
  }

  final formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  final componentChecker = TypeChecker.fromRuntime(BaseComponent);
  final controllerChecker = TypeChecker.fromRuntime(Controller);
  final configurationChecker = TypeChecker.fromRuntime(Configuration);
  final beanChecker = TypeChecker.fromRuntime(Bean);
  final bodyChecker = TypeChecker.fromRuntime(Body);
  final dtoChecker = TypeChecker.fromRuntime(DTO);
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

  @override
  Future<void> build(BuildStep buildStep) async {
    final aggregatedBuffer = StringBuffer();
    final dtoBuffer = StringBuffer();
    final importsBuffer = StringBuffer();

    final importSet = <String>{};

    importsBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    importsBuffer.writeln('// Aggregated Vaden application file');
    importsBuffer.writeln('// ignore_for_file: prefer_function_declarations_over_variables');
    importsBuffer.writeln();
    importsBuffer.writeln("import 'dart:convert';");
    importsBuffer.writeln("import 'dart:io';");
    importsBuffer.writeln("import 'package:vaden/vaden.dart';");
    importsBuffer.writeln();

    aggregatedBuffer.writeln('class VadenApplication {');
    aggregatedBuffer.writeln();
    aggregatedBuffer.writeln('  final _router = Router();');
    aggregatedBuffer.writeln('  final _injector = AutoInjector();');
    aggregatedBuffer.writeln('  Injector get injector => _injector;');
    aggregatedBuffer.writeln();
    aggregatedBuffer.writeln('  VadenApplication();');
    aggregatedBuffer.writeln();
    aggregatedBuffer.writeln('''
  Future<HttpServer> run() async {
    final pipeline = _injector.get<Pipeline>();
    final handler = pipeline.addHandler(_router.call);

    final settings = _injector.get<ApplicationSettings>();
    final port = settings['server']['port'] ?? 8080;
    final host = settings['server']['host'] ?? '0.0.0.0';

    final server = await serve(handler, host, port);

    return server;
  }
''');
    aggregatedBuffer.writeln();
    aggregatedBuffer.writeln('Future<void> setup() async {');
    aggregatedBuffer.writeln('final paths = <String, dynamic>{};');
    aggregatedBuffer.writeln('final apis = <Api>[];');
    aggregatedBuffer.writeln('_injector.addSingleton<DSON>(_DSON.new);');

    final body = await buildStep //
        .findAssets(Glob('lib/**/*.dart'))
        .asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (var classElement in reader.classes) {
        final component = componentChecker.firstAnnotationOf(classElement);
        if (component != null) {
          final registerWithInterfaceOrSuperType = component.getField('registerWithInterfaceOrSuperType')!.toBoolValue()!;

          yield (classElement, registerWithInterfaceOrSuperType);
          continue;
        }
      }
    }).map((record) {
      final (classElement, registerWithInterfaceOrSuperType) = record;
      final uri = classElement.librarySource.uri.toString();
      importSet.add(uri);
      return record;
    }).map((record) {
      final (classElement, registerWithInterfaceOrSuperType) = record;

      final bodyBuffer = StringBuffer();

      final registerText = _componentRegister(classElement, registerWithInterfaceOrSuperType);
      if (registerText.isNotEmpty) {
        bodyBuffer.writeln(registerText);
      }

      if (configurationChecker.hasAnnotationOf(classElement)) {
        bodyBuffer.writeln(_configurationSetup(classElement));
      } else if (controllerChecker.hasAnnotationOf(classElement)) {
        bodyBuffer.writeln(_controllerSetup(classElement));
      } else if (dtoChecker.hasAnnotationOf(classElement)) {
        dtoBuffer.writeln(dtoSetup(classElement));
      }

      return bodyBuffer.toString();
    }).toList();

    aggregatedBuffer.writeln(body.join('\n'));

    aggregatedBuffer.writeln('    _injector.addSingleton(OpenApiConfig.create(paths, apis).call);');
    aggregatedBuffer.writeln('    _injector.commit();');
    aggregatedBuffer.writeln('  }');
    aggregatedBuffer.writeln('}');

    importsBuffer.writeln(importSet.map((uri) => "import '$uri';").join('\n'));

    importsBuffer.writeln();
    importsBuffer.writeln(aggregatedBuffer.toString());

    importsBuffer.writeln();
    importsBuffer.writeln('''
class _DSON extends DSON {
  @override
  (Map<Type, FromJsonFunction>, Map<Type, ToJsonFunction>, Map<Type, ToOpenApiNormalMap>) getMaps() {
    final fromJsonMap = <Type, FromJsonFunction>{};
    final toJsonMap = <Type, ToJsonFunction>{};
    final toOpenApiMap = <Type, ToOpenApiNormalMap>{};

    $dtoBuffer

    return (fromJsonMap, toJsonMap, toOpenApiMap);
  }
}
''');

    final formattedCode = formatter.format(importsBuffer.toString());

    final outputId = _allFileOutput(buildStep);
    await buildStep.writeAsString(outputId, formattedCode);
  }

  String _componentRegister(ClassElement classElement, bool registerWithInterfaceOrSuperType) {
    if (dtoChecker.hasAnnotationOf(classElement) || configurationChecker.hasAnnotationOf(classElement)) {
      return '';
    }

    if (registerWithInterfaceOrSuperType) {
      final interfaceType = classElement.interfaces.firstOrNull ?? classElement.supertype;
      if (interfaceType != null && interfaceType.getDisplayString() != 'Object') {
        return '''
      _injector.addBind(Bind.withClassName(
      constructor: ${classElement.name}.new,
      type: BindType.singleton,
      className: '${interfaceType.getDisplayString()}',
    ));   
''';
      }
    }

    return '_injector.addSingleton(${classElement.name}.new);';
  }

  String _configurationSetup(ClassElement classElement) {
    final bodyBuffer = StringBuffer();

    final instanceName = 'configuration${classElement.name}';

    for (final method in classElement.methods) {
      if (beanChecker.hasAnnotationOf(method)) {
        if (method.returnType.isDartAsyncFuture) {
          log.severe('${method.name} is a Future method, but it is not supported in Configuration class.');
        } else {
          bodyBuffer.writeln('    _injector.addSingleton($instanceName.${method.name});');
        }
      }
    }

    if (bodyBuffer.isNotEmpty) {
      return '''final $instanceName = ${classElement.name}();

${bodyBuffer.toString()}
''';
    }

    return '';
  }

  String _controllerSetup(ClassElement classElement) {
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
      final description = controllerApi.getField('description')?.toStringValue() ?? '';
      api = Api(tag: tag, description: description);
      bodyBuffer.writeln("apis.add(const Api(tag: '${api.tag}', description: '${api.description}'));");
    }

    final controllerApiSecurityAnnotation = apiSecurityChecker.firstAnnotationOf(classElement);
    ApiSecurity? globalApiSecurity;

    if (controllerApiSecurityAnnotation != null) {
      final securitySchemes = controllerApiSecurityAnnotation.getField('schemes')?.toListValue() ?? [];
      final securityList = securitySchemes.map((e) => e.toStringValue()!).toList();
      globalApiSecurity = ApiSecurity(securityList);
    }

    final classGuards = useGuardsChecker.firstAnnotationOf(classElement);
    final classMidds = useMiddlewareChecker.firstAnnotationOf(classElement);

    final routerVar = "router$controllerName";
    bodyBuffer.writeln("final $routerVar = Router();");

    for (final method in classElement.methods) {
      String? routerMethod;
      String? routePath;

      for (final (checker, shelfMethod) in methodCheckers) {
        final httpAnn = checker.firstAnnotationOf(method);
        if (httpAnn != null) {
          routerMethod = shelfMethod;
          routePath = httpAnn.getField('path')?.toStringValue() ?? '';
          break;
        }
      }
      if (routerMethod == null) continue;

      final apiPathResolver = '$controllerPath$routePath'.replaceAll('<', '{').replaceAll('>', '}');

      if (api != null) {
        final convertSecurity = globalApiSecurity?.schemes.map((e) => "{'$e': []}").toList();
        final security = convertSecurity != null ? '[$convertSecurity]' : '<Map<String, dynamic>>[]';

        bodyBuffer.writeln("""
paths['$apiPathResolver'] = {
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

        final apiSecurityAnnotation = apiSecurityChecker.firstAnnotationOf(method);
        if (apiSecurityAnnotation != null) {
          final securitySchemes = apiSecurityAnnotation.getField('schemes')?.toListValue() ?? [];
          final securityList = securitySchemes.map((e) => "{'${e.toStringValue()}': []}").toList();
          bodyBuffer.writeln("paths['$apiPathResolver']['$routerMethod']['security'] = $securityList;");
        }

        final apiOperationAnnotation = apiOperationChecker.firstAnnotationOf(method);

        if (apiOperationAnnotation != null) {
          final summary = apiOperationAnnotation.getField('summary')?.toStringValue() ?? '';
          final description = apiOperationAnnotation.getField('description')?.toStringValue() ?? '';
          bodyBuffer.writeln("paths['$apiPathResolver']['$routerMethod']['summary'] = '$summary';");
          bodyBuffer.writeln("paths['$apiPathResolver']['$routerMethod']['description'] = '$description';");
        }

        final apiResponseAnnotations = apiResponseChecker.annotationsOf(method);

        for (final apiResponseAnnotation in apiResponseAnnotations) {
          final statusCode = apiResponseAnnotation.getField('statusCode')?.toIntValue() ?? 200;
          final description = apiResponseAnnotation.getField('description')?.toStringValue() ?? '';

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
                final schemaName = _extractListElementType(schema).getDisplayString();
                bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['responses']['$statusCode']['content']['$type']['schema'] = {
    'type': 'array',
    'items': {
      '\\\$ref': '#/components/schemas/$schemaName',
    },
};
""");
              } else {
                final schemaName = schema.getDisplayString();
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
            bodyBuffer.writeln("$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(guardTypeName)});");
          }
        }
      }
      if (classMidds != null) {
        final middList = classMidds.getField('middlewares')?.toListValue() ?? [];
        for (final m in middList) {
          final middTypeName = m.toTypeValue()?.getDisplayString();
          if (middTypeName != null) {
            bodyBuffer.writeln("$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(middTypeName)});");
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
            bodyBuffer.writeln("$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(guardTypeName)});");
          }
        }
      }
      if (methodMidds != null) {
        final middList = methodMidds.getField('middlewares')?.toListValue() ?? [];
        for (final m in middList) {
          final middTypeName = m.toTypeValue()?.getDisplayString();
          if (middTypeName != null) {
            bodyBuffer.writeln("$pipelineVar = $pipelineVar.addMiddleware(${wrapMiddleware(middTypeName)});");
          }
        }
      }

      final paramCodeList = <String>[];
      for (final parameter in method.parameters) {
        if (bodyChecker.hasAnnotationOf(parameter)) {
          final typeName = parameter.type.getDisplayString();

          if (api != null) {
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

          paramCodeList.add("""
final bodyString = await request.readAsString();
final json = jsonDecode(bodyString) as Map<String, dynamic>;
final ${parameter.name} =  _injector.get<DSON>().fromJson<$typeName>(json) as dynamic;

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
    return Response(400, body: jsonEncode(resultValidator.exceptionToJson()));
  }
}
""");
        } else if (paramChecker.hasAnnotationOf(parameter)) {
          final pname = paramChecker.firstAnnotationOf(parameter)?.getField('name')?.toStringValue() ?? parameter.name;

          if (api != null) {
            bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['parameters']?.add({
  'name': '$pname',
  'in': 'path',
  'required': ${!_isNullable(parameter.type)},
  'schema': {
    'type': 'string',
  },
});
""");
          }

          paramCodeList.add("""
  if (request.params['$pname'] == null) {
    return Response(400, body: jsonEncode({'error': 'Invalid parameter ($pname)'}));
  }
  final ${parameter.name} = request.params['$pname']!;

""");
        } else if (queryChecker.hasAnnotationOf(parameter)) {
          final qname = queryChecker.firstAnnotationOf(parameter)?.getField('name')?.toStringValue() ?? parameter.name;
          if (api != null) {
            bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['parameters']?.add({
  'name': '$qname',
  'in': 'path',
  'required': ${!_isNullable(parameter.type)},
  'schema': {
    'type': 'string',
  },
});
""");
          }
          paramCodeList.add("final ${parameter.name} = request.url.queryParameters['$qname'];");
        } else if (headerChecker.hasAnnotationOf(parameter)) {
          final hname = headerChecker.firstAnnotationOf(parameter)?.getField('name')?.toStringValue() ?? parameter.name;
          if (api != null) {
            bodyBuffer.writeln("""
paths['$apiPathResolver']['$routerMethod']['parameters']?.add({
  'name': '$hname',
  'in': 'header',
  'required': ${!_isNullable(parameter.type)},
  'schema': {
    'type': 'string',
  },
});
""");
          }
          paramCodeList.add("final ${parameter.name} = request.headers['$hname'];");
        } else if (contextChecker.hasAnnotationOf(parameter)) {
          final cname = contextChecker.firstAnnotationOf(parameter)?.getField('name')?.toStringValue() ?? parameter.name;
          final ctype = parameter.type.getDisplayString();
          paramCodeList.add("final ${parameter.name} = request.context['$cname'] as $ctype;");
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
      bodyBuffer.writeln("  final ctrl = _injector.get<$controllerName>();");
      bodyBuffer.writeln("  final result = await ctrl.${method.name}($callParams);");
      bodyBuffer.writeln("  return result;");
      bodyBuffer.writeln("};");

      bodyBuffer.writeln("$routerVar.$routerMethod('$routePath', $pipelineVar.addHandler($handlerVar));");

      // documetation
    }

    // Concatena o router do controller com o router global
    bodyBuffer.writeln("_router.mount('$controllerPath', $routerVar.call);");

    return bodyBuffer.toString();
  }

  DartType _extractListElementType(DartType type) {
    if (type is ParameterizedType && type.isDartCoreList && type.typeArguments.isNotEmpty) {
      return type.typeArguments.first;
    }
    throw Exception('O tipo não é um List<T> ou não possui argumentos de tipo.');
  }

  bool _isNullable(DartType type) {
    return type.nullabilitySuffix != NullabilitySuffix.none;
  }
}

Builder aggregatingVadenBuilder(BuilderOptions options) => AggregatingVadenBuilder();
