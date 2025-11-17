import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:vaden_class_scanner/src/setups/initial.dart';

class FlutterVadenBuilder implements Builder {
  FlutterVadenBuilder();

  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$package$': ['lib/vaden_application.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final aggregatedBuffer = StringBuffer();
    final dtoBuffer = StringBuffer();
    final importsBuffer = StringBuffer();
    final apiClientBuffer = StringBuffer();
    final moduleRegisterBuffer = StringBuffer();
    final exceptionHandlerBuffer = StringBuffer();

    final importSet = <String>{};

    importsBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    importsBuffer.writeln('// Aggregated Vaden application file');
    importsBuffer.writeln(
      '// ignore_for_file: prefer_func  tion_declarations_over_variables, implementation_imports',
    );

    aggregatedBuffer.writeln('''
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dioPackage;
import 'package:flutter_vaden/flutter_vaden.dart';

 late final AutoInjector _injector;

class VadenApp extends FlutterVadenApplication {

  @override
  AutoInjector get injector => _injector;

  VadenApp({
    required super.child,
    AutoInjector? injector,
  }){
    _injector = injector ?? AutoInjector();
  }

''');

    aggregatedBuffer.writeln('''
  @override
  Future<void> setup() async {
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);
    _injector.addInstance<Injector>(_injector);
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
    components.sort((a, b) => a.priority.priority.compareTo(b.priority.priority));

    final body = components.map((c) => c.code).toList();

    aggregatedBuffer.writeln(body.join('\n'));

    aggregatedBuffer.writeln('    _injector.commit();');
    aggregatedBuffer.writeln('''

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }

''');

    aggregatedBuffer.writeln('$moduleRegisterBuffer');
    aggregatedBuffer.writeln('  }');

    aggregatedBuffer.writeln('}');

    importsBuffer.writeln(importSet.map((uri) => "import $uri").join('\n'));

    importsBuffer.writeln();
    importsBuffer.writeln(aggregatedBuffer.toString());

    importsBuffer.writeln();
    importsBuffer.writeln(dsonGenerate(dtoBuffer.toString()));

    if (apiClientBuffer.isNotEmpty) {
      importsBuffer.writeln();
      importsBuffer.writeln(apiClientBuffer.toString());
    }

    writeAndFormatApplication(importsBuffer.toString(), buildStep);
  }
}
