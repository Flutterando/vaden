import 'dart:async';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:vaden_class_scanner/src/setups/initial.dart';

class BackendVadenBuilder implements Builder {
  BackendVadenBuilder();

  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$package$': ['lib/vaden_application.dart'],
  };

  final formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

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
    importsBuffer.writeln(
      '// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports',
    );

    aggregatedBuffer.writeln('''
import 'dart:convert';
import 'dart:io';
import 'package:vaden/vaden.dart';

class VadenApp implements DartVadenApplication {
  final _router = Router();
  final _injector = AutoInjector();
  
  @override
  AutoInjector get injector => _injector;  
  
  @override
  Router get router => _router;

  VadenApp();

  @override
  Future<HttpServer> run(List<String> args) async {
    _injector.tryGet<CommandLineRunner>()?.run(args);
    _injector.tryGet<ApplicationRunner>()?.run(this);
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

    aggregatedBuffer.writeln('''
  @override
  Future<void> setup() async {
    final paths = <String, dynamic>{};
    final apis = <Api>[];
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);
''');

    final components =
        await buildStep //
            .findAssets(Glob('lib/**.dart'))
            .asyncExpand(checkImports(buildStep, importSet))
            .map(
              selectComponentWithPriority(
                dtoBuffer: dtoBuffer,
                exceptionHandlerBuffer: exceptionHandlerBuffer,
                moduleRegisterBuffer: moduleRegisterBuffer,
                importSet: importSet,
              ),
            )
            .toList();

    // Sort components by priority to ensure correct registration order
    // Configurations first, then regular components, then controllers
    components.sort(
      (a, b) => a.priority.priority.compareTo(b.priority.priority),
    );

    final body = components.map((c) => c.code).toList();

    aggregatedBuffer.writeln(body.join('\n'));

    aggregatedBuffer.writeln(
      '    _injector.addLazySingleton(OpenApiConfig.create(paths, apis).call);',
    );
    aggregatedBuffer.writeln('    _injector.commit();');
    aggregatedBuffer.writeln('''

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }

''');

    aggregatedBuffer.writeln('$moduleRegisterBuffer');
    aggregatedBuffer.writeln('  }');
    aggregatedBuffer.writeln(
      '''Future<Response> _handleException(dynamic e) async {

    $exceptionHandlerBuffer

    return Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));
  }
''',
    );

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
    importsBuffer.writeln(dsonGenerate(dtoBuffer.toString()));

    writeAndFormatApplication(importsBuffer.toString(), buildStep);
  }
}
