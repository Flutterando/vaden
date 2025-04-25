import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_class_scanner/src/setups/configuration_setup.dart';
import 'package:vaden_class_scanner/src/setups/controller_advice_setup.dart';
import 'package:vaden_class_scanner/src/setups/controller_setup.dart';

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
  final dtoChecker = TypeChecker.fromRuntime(DTO);
  final moduleChecker = TypeChecker.fromRuntime(VadenModule);
  final parseChecker = TypeChecker.fromRuntime(Parse);

  @override
  Future<void> build(BuildStep buildStep) async {
    final aggregatedBuffer = StringBuffer();
    final dtoBuffer = StringBuffer();
    final importsBuffer = StringBuffer();
    final exceptionHandlerBuffer = StringBuffer();
    final moduleRegisterBuffer = StringBuffer();

    final importSet = <String>{};

    importsBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    importsBuffer.writeln('// Aggregated Vaden application file');
    importsBuffer.writeln('// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports');
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
    final handler = pipeline.addHandler((request) async {
      try {
        final response = await _router(request);
        return response;
      } catch (e, stack) {
        print(e);
        print(stack);
        return _handleException(e);
      }
    });

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
    aggregatedBuffer.writeln('final asyncBeans = <Future<void> Function()>[];');
    aggregatedBuffer.writeln('_injector.addLazySingleton<DSON>(_DSON.new);');

    final body = await buildStep //
        .findAssets(Glob('lib/**/*.dart'))
        .asyncExpand((assetId) async* {
      final library = await buildStep.resolver.libraryFor(assetId);
      final reader = LibraryReader(library);

      for (var classElement in reader.classes) {
        yield* _checkMasterAnnotations(classElement);
      }
    }).map((record) {
      final (classElement, registerWithInterfaceOrSuperType) = record;
      final uri = classElement.librarySource.uri.toString();
      importSet.add("'$uri';");
      return record;
    }).map((record) {
      final (classElement, registerWithInterfaceOrSuperType) = record;

      final bodyBuffer = StringBuffer();

      final registerText = _componentRegister(classElement, registerWithInterfaceOrSuperType);
      if (registerText.isNotEmpty) {
        bodyBuffer.writeln(registerText);
      }

      if (configurationChecker.hasAnnotationOf(classElement)) {
        bodyBuffer.writeln(configurationSetup(classElement));
      } else if (controllerChecker.hasAnnotationOf(classElement)) {
        bodyBuffer.writeln(controllerSetup(classElement));
      } else if (dtoChecker.hasAnnotationOf(classElement)) {
        dtoBuffer.writeln(dtoSetup(classElement));
      } else if (controllerAdviceChecker.hasAnnotationOf(classElement)) {
        final (adviceBody, imports) = controllerAdviceSetup(classElement);

        if (adviceBody.isNotEmpty) {
          exceptionHandlerBuffer.writeln(adviceBody);
        }

        importSet.addAll(imports);
      } else if (moduleChecker.hasAnnotationOf(classElement)) {
        final name = classElement.name;

        moduleRegisterBuffer.writeln('await $name().register(_router, _injector);');
      }

      return bodyBuffer.toString();
    }).toList();

    aggregatedBuffer.writeln(body.join('\n'));

    aggregatedBuffer.writeln('    _injector.addLazySingleton(OpenApiConfig.create(paths, apis).call);');
    aggregatedBuffer.writeln('    _injector.commit();');
    aggregatedBuffer.writeln('''

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }

''');

    aggregatedBuffer.writeln('$moduleRegisterBuffer');
    aggregatedBuffer.writeln('  }');
    aggregatedBuffer.writeln('''Future<Response> _handleException(dynamic e) async {

    $exceptionHandlerBuffer

    return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
  }
''');

    aggregatedBuffer.writeln('''PType? _parse<PType>(String? value) {
    if (value == null) {
      return null;
    }

    if(PType == int) {
      return int.parse(value) as PType;
    } else if(PType == double) {
      return double.parse(value) as PType;
    } else if(PType == bool) {
      return bool.parse(value) as PType;
    } else {
      return value as PType;
    }
  }
    ''');
    aggregatedBuffer.writeln('}');

    importsBuffer.writeln(importSet.map((uri) => "import $uri").join('\n'));

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

    final outputId = _allFileOutput(buildStep);

    try {
      final formattedCode = formatter.format(importsBuffer.toString());
      await buildStep.writeAsString(outputId, formattedCode);
    } catch (e) {
      await buildStep.writeAsString(outputId, importsBuffer.toString());
    }
  }

  String _componentRegister(ClassElement classElement, bool registerWithInterfaceOrSuperType) {
    if (dtoChecker.hasAnnotationOf(classElement) || configurationChecker.hasAnnotationOf(classElement)) {
      return '';
    } else if (moduleChecker.hasAnnotationOf(classElement)) {
      return '';
    } else if (parseChecker.hasAnnotationOf(classElement)) {
      return '';
    }

    if (registerWithInterfaceOrSuperType) {
      final interfaceType = classElement.interfaces.firstOrNull ?? classElement.supertype;
      if (interfaceType != null && interfaceType.getDisplayString() != 'Object') {
        return '''
      _injector.addBind(Bind.withClassName(
      constructor: ${classElement.name}.new,
      type: BindType.lazySingleton,
      className: '${interfaceType.getDisplayString()}',
    ));   
''';
      }
    }

    return '_injector.addLazySingleton(${classElement.name}.new);';
  }

  Stream<(ClassElement, bool)> _checkMasterAnnotations(ClassElement classElement) async* {
    final component = componentChecker.firstAnnotationOf(classElement);
    if (component != null) {
      final registerWithInterfaceOrSuperType = component.getField('registerWithInterfaceOrSuperType')!.toBoolValue()!;

      yield (classElement, registerWithInterfaceOrSuperType);
    } else if (moduleChecker.hasAnnotationOf(classElement)) {
      final module = moduleChecker.firstAnnotationOf(classElement)!;
      final vadenModules = module.getField('imports')!.toListValue() ?? [];
      for (var module in vadenModules) {
        final element = module.toTypeValue()?.element;

        if (element is! ClassElement) {
          continue;
        }

        final innerModule = moduleChecker.firstAnnotationOf(element);
        if (innerModule == null) {
          continue;
        }

        yield (element, false);

        final types = innerModule.getField('imports')?.toListValue() ?? [];

        for (var type in types) {
          final typeElement = type.toTypeValue()?.element;
          if (typeElement is ClassElement) {
            yield* _checkMasterAnnotations(typeElement);
          }
        }
      }
    }
  }
}

Builder aggregatingVadenBuilder(BuilderOptions options) => AggregatingVadenBuilder();
