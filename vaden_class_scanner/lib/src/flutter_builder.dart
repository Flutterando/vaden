import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:vaden_class_scanner/src/setups/api_client_setup.dart';
import 'package:vaden_class_scanner/src/setups/configuration_setup.dart';
import 'package:vaden_core/vaden_core.dart';

import 'setups/dto_setup.dart';
import 'setups/storage_setup.dart';

class FlutterVadenBuilder implements Builder {
  FlutterVadenBuilder();

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

  final formatter =
      DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  final componentChecker = TypeChecker.fromRuntime(BaseComponent);
  final dtoChecker = TypeChecker.fromRuntime(DTO);
  final moduleChecker = TypeChecker.fromRuntime(VadenModule);
  final parseChecker = TypeChecker.fromRuntime(Parse);
  final apiClientChecker = TypeChecker.fromRuntime(ApiClient);
  final storageChecker = TypeChecker.fromRuntime(LocalStorage);

  @override
  Future<void> build(BuildStep buildStep) async {
    final aggregatedBuffer = StringBuffer();
    final dtoBuffer = StringBuffer();
    final importsBuffer = StringBuffer();
    final apiClientBuffer = StringBuffer();
    final storageBuffer = StringBuffer();
    final moduleRegisterBuffer = StringBuffer();

    final importSet = <String>{};

    importsBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    importsBuffer.writeln('// Aggregated Vaden application file');
    importsBuffer.writeln(
        '// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports');

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
''');

    final body = await buildStep //
        .findAssets(Glob('lib/**.dart'))
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

      final registerText =
          _componentRegister(classElement, registerWithInterfaceOrSuperType);
      if (registerText.isNotEmpty) {
        bodyBuffer.writeln(registerText);
      }

      if (configurationChecker.hasAnnotationOf(classElement)) {
        bodyBuffer.writeln(configurationSetup(classElement));
      } else if (dtoChecker.hasAnnotationOf(classElement)) {
        dtoBuffer.writeln(dtoSetup(classElement));
      } else if (moduleChecker.hasAnnotationOf(classElement)) {
        final name = classElement.name;

        if (classElement.allSupertypes.any(
            (type) => type.getDisplayString().startsWith('CommonModule'))) {
          moduleRegisterBuffer.writeln('await $name().register(this);');
        }
      } else if (apiClientChecker.hasAnnotationOf(classElement)) {
        final basePath = apiClientChecker
                .firstAnnotationOf(classElement)
                ?.getField('basePath')
                ?.toStringValue() ??
            '';
        apiClientBuffer.writeln(apiClientSetup(classElement, basePath));
      } else if (storageChecker.hasAnnotationOf(classElement)) {
        storageBuffer.writeln(storageClientSetup(classElement));
      }
      return bodyBuffer.toString();
    }).toList();

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

    if (apiClientBuffer.isNotEmpty) {
      importsBuffer.writeln();
      importsBuffer.writeln(apiClientBuffer.toString());
    }

    if (storageBuffer.isNotEmpty) {
      importsBuffer.writeln();
      importsBuffer.writeln(storageBuffer.toString());
    }

    final outputId = _allFileOutput(buildStep);

    try {
      final formattedCode = formatter.format(importsBuffer.toString());
      await buildStep.writeAsString(outputId, formattedCode);
    } catch (e) {
      await buildStep.writeAsString(outputId, importsBuffer.toString());
    }
  }

  String _componentRegister(
      ClassElement classElement, bool registerWithInterfaceOrSuperType) {
    if (dtoChecker.hasAnnotationOf(classElement) ||
        configurationChecker.hasAnnotationOf(classElement)) {
      return '';
    } else if (moduleChecker.hasAnnotationOf(classElement)) {
      return '';
    } else if (parseChecker.hasAnnotationOf(classElement)) {
      return '';
    }

    if (registerWithInterfaceOrSuperType) {
      final interfaceType =
          classElement.interfaces.firstOrNull ?? classElement.supertype;
      if (interfaceType != null &&
          interfaceType.getDisplayString() != 'Object') {
        return '''
      _injector.addBind(Bind.withClassName(
      constructor: ${classElement.name}.new,
      type: BindType.lazySingleton,
      className: '${interfaceType.getDisplayString()}',
    ));   
''';
      }
    }

    if (apiClientChecker.hasAnnotationOf(classElement)) {
      return '_injector.addLazySingleton<${classElement.name}>(_${classElement.name}.new);';
    }

    if (storageChecker.hasAnnotationOf(classElement)) {
      return '_injector.addLazySingleton<${classElement.name}>(_${classElement.name}.new);';
    }

    return '_injector.addLazySingleton(${classElement.name}.new);';
  }

  Stream<(ClassElement, bool)> _checkMasterAnnotations(
      ClassElement classElement) async* {
    final component = componentChecker.firstAnnotationOf(classElement);
    if (component != null) {
      final registerWithInterfaceOrSuperType = component
          .getField('registerWithInterfaceOrSuperType')!
          .toBoolValue()!;

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
