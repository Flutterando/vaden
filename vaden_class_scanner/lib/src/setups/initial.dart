import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:vaden_class_scanner/src/setups/api_client_setup.dart';
import 'package:vaden_class_scanner/src/setups/configuration_setup.dart';
import 'package:vaden_class_scanner/src/setups/controller_advice_setup.dart';
import 'package:vaden_class_scanner/src/setups/controller_setup.dart';
import 'package:vaden_class_scanner/src/setups/dto_setup.dart';
import 'package:vaden_core/vaden_core.dart';

final formatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
);

/// Defines the priority order for component registration
/// to ensure dependencies are resolved in the correct order.
enum ComponentPriority {
  /// Configuration classes - processed first to register beans
  configuration(0),

  /// Regular components (Services, Repositories, etc.)
  component(1),

  /// Controllers - processed last as they depend on other components
  controller(2),

  /// DTOs and other non-injectable types
  other(3);

  const ComponentPriority(this.priority);
  final int priority;
}

/// Represents a component with its registration code and priority
class ComponentRegistration {
  final String code;
  final ComponentPriority priority;

  ComponentRegistration(this.code, this.priority);
}

final componentChecker = TypeChecker.typeNamed(
  BaseComponent,
  inPackage: 'vaden_core',
);

final moduleChecker = TypeChecker.typeNamed(
  VadenModule,
  inPackage: 'vaden_core',
);

final apiClientChecker = TypeChecker.typeNamed(
  ApiClient,
  inPackage: 'vaden_core',
);

final dtoChecker = TypeChecker.typeNamed(DTO, inPackage: 'vaden_core');

final scopeChecker = TypeChecker.typeNamed(Scope, inPackage: 'vaden_core');
final parseChecker = TypeChecker.typeNamed(Parse, inPackage: 'vaden_core');

Stream<(ClassElement, bool)> Function(AssetId) checkImports(
  BuildStep buildStep,
  Set<String> importSet,
) {
  return (AssetId assetId) => _checkImports(assetId, buildStep, importSet);
}

Stream<(ClassElement, bool)> _checkImports(
  AssetId assetId,
  BuildStep buildStep,
  Set<String> importSet,
) async* {
  final library = await buildStep.resolver.libraryFor(assetId);
  final reader = LibraryReader(library);

  // build the package import URI from the AssetId
  var assetPath = assetId.path;
  if (assetPath.startsWith('lib/')) {
    assetPath = assetPath.substring(4);
  }
  final importUri = 'package:${assetId.package}/$assetPath';

  for (var classElement in reader.classes) {
    await for (final record in _checkMasterAnnotations(classElement)) {
      final (ce, registerWithInterfaceOrSuperType) = record;

      String elementImportUri;
      if (ce == classElement) {
        elementImportUri = importUri;
      } else {
        final elementLibrary = ce.library;
        if (elementLibrary.uri.toString().isNotEmpty) {
          elementImportUri = elementLibrary.uri.toString();
        } else {
          elementImportUri = importUri;
        }
      }

      importSet.add("'$elementImportUri';");
      yield (ce, registerWithInterfaceOrSuperType);
    }
  }
}

Stream<(ClassElement, bool)> _checkMasterAnnotations(
  ClassElement classElement,
) async* {
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
  } else if (scopeChecker.hasAnnotationOf(classElement)) {
    yield (classElement, false);
  }
}

/// Returns ComponentRegistration for proper ordering
ComponentRegistration Function((ClassElement, bool))
selectComponentWithPriority({
  required StringBuffer dtoBuffer,
  required StringBuffer exceptionHandlerBuffer,
  required StringBuffer moduleRegisterBuffer,
  required Set<String> importSet,
  StringBuffer? apiClientBuffer,
}) {
  return (record) => _selectComponent(
    record: record,
    dtoBuffer: dtoBuffer,
    exceptionHandlerBuffer: exceptionHandlerBuffer,
    moduleRegisterBuffer: moduleRegisterBuffer,
    importSet: importSet,
    apiClientBuffer: apiClientBuffer,
  );
}

ComponentRegistration _selectComponent({
  required (ClassElement, bool) record,
  required StringBuffer dtoBuffer,
  required StringBuffer exceptionHandlerBuffer,
  required StringBuffer moduleRegisterBuffer,
  required Set<String> importSet,
  StringBuffer? apiClientBuffer,
}) {
  final (classElement, registerWithInterfaceOrSuperType) = record;

  final bodyBuffer = StringBuffer();
  ComponentPriority priority = ComponentPriority.other;

  final registerText = _componentRegister(
    classElement,
    registerWithInterfaceOrSuperType,
  );
  if (registerText.isNotEmpty) {
    bodyBuffer.writeln(registerText);
  }

  if (configurationChecker.hasAnnotationOf(classElement)) {
    bodyBuffer.writeln(configurationSetup(classElement));
    priority = ComponentPriority.configuration;
  } else if (controllerChecker.hasAnnotationOf(classElement)) {
    bodyBuffer.writeln(controllerSetup(classElement));
    _collectFieldTypeImports(classElement, importSet);
    _collectMethodParamTypeImports(classElement, importSet);
    priority = ComponentPriority.controller;
  } else if (apiClientBuffer != null &&
      apiClientChecker.hasAnnotationOf(classElement)) {
    final basePath =
        apiClientChecker
            .firstAnnotationOf(classElement)
            ?.getField('basePath')
            ?.toStringValue() ??
        '';
    apiClientBuffer.writeln(apiClientSetup(classElement, basePath));
    priority = ComponentPriority.component;
  } else if (dtoChecker.hasAnnotationOf(classElement)) {
    dtoBuffer.writeln(dtoSetup(classElement));
    _collectFieldTypeImports(classElement, importSet);
    priority = ComponentPriority.other;
  } else if (controllerAdviceChecker.hasAnnotationOf(classElement)) {
    final (adviceBody, imports) = controllerAdviceSetup(classElement);

    if (adviceBody.isNotEmpty) {
      exceptionHandlerBuffer.writeln(adviceBody);
    }

    importSet.addAll(imports);
    priority = ComponentPriority.other;
  } else if (moduleChecker.hasAnnotationOf(classElement)) {
    final name = classElement.name;

    if (classElement.allSupertypes.any(
      (type) => type.getDisplayString().startsWith('CommonModule'),
    )) {
      moduleRegisterBuffer.writeln('await $name().register(this);');
    }
    priority = ComponentPriority.other;
  } else if (registerText.isNotEmpty) {
    // Regular components (Services, Repositories, etc.)
    priority = ComponentPriority.component;
  }

  return ComponentRegistration(bodyBuffer.toString(), priority);
}

String _componentRegister(
  ClassElement classElement,
  bool registerWithInterfaceOrSuperType,
) {
  if (dtoChecker.hasAnnotationOf(classElement) ||
      configurationChecker.hasAnnotationOf(classElement)) {
    return '';
  } else if (moduleChecker.hasAnnotationOf(classElement)) {
    return '';
  } else if (parseChecker.hasAnnotationOf(classElement)) {
    return '';
  }

  String? scopeType;
  String? bindType = 'BindType.lazySingleton';

  // Check if the class is annotated with @Scope
  final scopeAnnotation = scopeChecker.firstAnnotationOf(classElement);

  if (scopeAnnotation != null) {
    scopeType = scopeAnnotation.getField('type')?.variable?.name?.toLowerCase();

    if (scopeType == 'instance') {
      bindType = 'BindType.instance';
    } else if (scopeType == 'singleton') {
      bindType = 'BindType.singleton';
    } else if (scopeType == 'lazysingleton') {
      bindType = 'BindType.lazySingleton';
    } else if (scopeType == 'factory') {
      bindType = 'BindType.factory';
    }
  }

  if (registerWithInterfaceOrSuperType) {
    final interfaceType =
        classElement.interfaces.firstOrNull ?? classElement.supertype;
    if (interfaceType != null && interfaceType.getDisplayString() != 'Object') {
      // Don't register VadenMiddleware or VadenGuard by their supertype
      // as multiple implementations would conflict
      final supertypeDisplay = interfaceType.getDisplayString();
      final isMiddlewareOrGuard =
          supertypeDisplay == 'VadenMiddleware' ||
          supertypeDisplay == 'VadenGuard';

      if (!isMiddlewareOrGuard) {
        return '''
      _injector.addBind(Bind.withClassName(
      constructor: ${classElement.name}.new,
      type: $bindType,
      className: '${interfaceType.getDisplayString()}',
    ));   
''';
      }
    }
  }

  if (scopeType == 'instance') {
    return '_injector.add(${classElement.name}.new);';
  } else if (scopeType == 'lazysingleton') {
    return '_injector.addLazySingleton(${classElement.name}.new);';
  } else if (scopeType == 'singleton') {
    return '_injector.addSingleton(${classElement.name}.new);';
  } else if (scopeType == 'factory') {
    return '''
        _injector.addBind(Bind.withClassName(
        constructor: ${classElement.name}.new,
        type: BindType.$scopeType,
      ));   
    ''';
  }

  /// If the class is annotated with @Controller, we register it as a instance.
  if (controllerChecker.hasAnnotationOf(classElement)) {
    return '_injector.add(${classElement.name}.new);';
  }

  if (apiClientChecker.hasAnnotationOf(classElement)) {
    return '_injector.addLazySingleton<${classElement.name}>(_${classElement.name}.new);';
  }

  return '_injector.addLazySingleton(${classElement.name}.new);';
}

String dsonGenerate(String dto) {
  return ''' 
  class _DSON extends DSON {
  @override
  (Map<Type, FromJsonFunction>, Map<Type, ToJsonFunction>, Map<Type, ToOpenApiNormalMap>) getMaps() {
    final fromJsonMap = <Type, FromJsonFunction>{};
    final toJsonMap = <Type, ToJsonFunction>{};
    final toOpenApiMap = <Type, ToOpenApiNormalMap>{};

    $dto

    return (fromJsonMap, toJsonMap, toOpenApiMap);
  }
}
  ''';
}

Future<void> writeAndFormatApplication(String text, BuildStep buildStep) async {
  final outputId = AssetId(
    buildStep.inputId.package,
    p.join('lib', 'vaden_application.dart'),
  );

  try {
    final formattedCode = formatter.format(text);
    await buildStep.writeAsString(outputId, formattedCode);
  } catch (e) {
    await buildStep.writeAsString(outputId, text);
  }
}

/// Adds import URIs for non-primitive types referenced by the fields of
/// [classElement] (and its supertypes) that are not already covered by
/// annotation-based scanning. This handles enums and other types defined
/// in separate files.
void _collectFieldTypeImports(
  ClassElement classElement,
  Set<String> importSet,
) {
  ClassElement? current = classElement;
  while (current != null) {
    for (final field in current.fields) {
      if (field.isSynthetic || field.isStatic || field.isPrivate) continue;
      _addTypeImport(field.type, importSet);
    }
    final superType = current.supertype;
    if (superType == null || superType.isDartCoreObject) break;
    current = superType.element as ClassElement?;
  }
}

/// Adds import URIs for non-primitive types referenced by method parameters
/// of [classElement], covering @Param, @Query and @Body enum types in
/// controllers. Traverses supertypes to match the same method resolution
/// used by [controllerSetup].
void _collectMethodParamTypeImports(
  ClassElement classElement,
  Set<String> importSet,
) {
  final visited = <String>{};

  void collectFromMethods(InterfaceElement element) {
    for (final method in element.methods) {
      if (method.isStatic || method.isPrivate) continue;
      final name = method.name;
      if (name == null || !visited.add(name)) continue;
      for (final param in method.formalParameters) {
        _addTypeImport(param.type, importSet);
      }
      _addTypeImport(method.returnType, importSet);
    }
  }

  collectFromMethods(classElement);

  for (final supertype in classElement.allSupertypes) {
    if (supertype.element.name == 'Object') continue;
    collectFromMethods(supertype.element);
  }
}

/// Resolves the library URI for [type] and adds it to [importSet] if it is
/// a non-core type (enum, class, etc.) defined outside of dart:core.
void _addTypeImport(DartType type, Set<String> importSet) {
  // Unwrap Future / FutureOr
  if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
    if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
      _addTypeImport(type.typeArguments.first, importSet);
    }
    return;
  }

  // Unwrap List / Set / Map type arguments
  if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
    for (final arg in type.typeArguments) {
      _addTypeImport(arg, importSet);
    }
  }

  final element = type.element;
  if (element == null) return;

  // Skip dart:core types (int, String, bool, etc.)
  final uri = element.library?.uri.toString() ?? '';
  if (uri.isEmpty || uri.startsWith('dart:')) return;

  importSet.add("'$uri';");
}
