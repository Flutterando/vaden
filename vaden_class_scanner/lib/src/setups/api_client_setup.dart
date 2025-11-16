import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden_core/vaden_core.dart';

final bodyChecker = TypeChecker.typeNamed(Body, inPackage: 'vaden_core');
final paramChecker = TypeChecker.typeNamed(Param, inPackage: 'vaden_core');
final queryChecker = TypeChecker.typeNamed(Query, inPackage: 'vaden_core');
final headerChecker = TypeChecker.typeNamed(Header, inPackage: 'vaden_core');

final methodCheckers = <(TypeChecker, String)>[
  (TypeChecker.typeNamed(Get, inPackage: 'vaden_core'), 'GET'),
  (TypeChecker.typeNamed(Post, inPackage: 'vaden_core'), 'POST'),
  (TypeChecker.typeNamed(Put, inPackage: 'vaden_core'), 'PUT'),
  (TypeChecker.typeNamed(Patch, inPackage: 'vaden_core'), 'PATCH'),
  (TypeChecker.typeNamed(Delete, inPackage: 'vaden_core'), 'DELETE'),
  (TypeChecker.typeNamed(Head, inPackage: 'vaden_core'), 'HEAD'),
  (TypeChecker.typeNamed(Options, inPackage: 'vaden_core'), 'OPTIONS'),
];

String apiClientSetup(ClassElement classElement, String basePath) {
  final bodyBuffer = StringBuffer();

  bodyBuffer.writeln('''
  class _${classElement.name} implements ${classElement.name} {
    final DSON dson;

    _${classElement.name}(this.dson);

''');

  for (final method in classElement.methods) {
    bodyBuffer.writeln('@override');
    final methodName = method.name;
    final returnType = _getFutureType(method.returnType);
    final isVoidReturn = returnType.getDisplayString() == 'void';
    final parameters = method.formalParameters;

    final parameterList = parameters
        .map((param) {
          final type = param.type.getDisplayString();
          return '${param.isNamed ? '' : type} ${param.name}';
        })
        .join(', ');

    bodyBuffer.write('''
    Future<$returnType> $methodName($parameterList) async {
    final dio = _injector.tryGet<dioPackage.Dio>() ?? dioPackage.Dio();
''');

    final methodChecker = methodCheckers.firstWhere(
      (checker) => checker.$1.hasAnnotationOfExact(method),
    );

    final methodAnnotation = methodChecker.$1.firstAnnotationOfExact(method);

    var methodPath = methodAnnotation?.getField('path')?.toStringValue() ?? '/';

    if (basePath.isNotEmpty) {
      methodPath = '$basePath$methodPath';
    }

    final methodType = methodChecker.$2;

    final paramReplacements = parameters
        .where((param) => paramChecker.hasAnnotationOfExact(param))
        .map((param) {
          final paramAnnotation = paramChecker.firstAnnotationOfExact(param);
          final paramName =
              paramAnnotation?.getField('name')?.toStringValue() ?? param.name;
          return MapEntry('<$paramName>', param.name);
        });

    for (final replacement in paramReplacements) {
      methodPath = methodPath.replaceAll(
        replacement.key,
        '\$${replacement.value}',
      );
    }

    final bodyParam = parameters.firstWhereOrNull(
      (param) => bodyChecker.hasAnnotationOfExact(param),
    );

    final bodyCode = bodyParam != null
        ? bodyParam.type.isDartCoreList
              ? 'data: dson.toJsonList<${_getListType(bodyParam.type).getDisplayString()}>(${bodyParam.name})'
              : 'data: dson.toJson<${bodyParam.type.getDisplayString()}>(${bodyParam.name})'
        : '';

    final headerParams = parameters
        .where((param) => headerChecker.hasAnnotationOfExact(param))
        .map((param) {
          final headerAnnotation = headerChecker.firstAnnotationOfExact(param);
          final headerName =
              headerAnnotation?.getField('name')?.toStringValue() ?? param.name;
          return MapEntry(headerName, param.name);
        });

    final headersCode = headerParams.isNotEmpty
        ? 'headers: {${headerParams.map((entry) => "'${entry.key}': ${entry.value}").join(', ')}}'
        : '';

    final queryParams = parameters
        .where((param) => queryChecker.hasAnnotationOfExact(param))
        .map((param) {
          final queryAnnotation = queryChecker.firstAnnotationOfExact(param);
          final queryName =
              queryAnnotation?.getField('name')?.toStringValue() ?? param.name;
          return MapEntry(queryName, param.name);
        });

    final queryCode = queryParams.isNotEmpty
        ? 'queryParameters: {${queryParams.map((entry) => "'${entry.key}': ${entry.value}").join(', ')}}'
        : '';

    if (!isVoidReturn) {
      bodyBuffer.write('final response = ');
    }

    bodyBuffer.write('''await dio.request(
      '$methodPath',
      options: dioPackage.Options(method: '$methodType', ${headersCode.isNotEmpty ? headersCode : ''}),
''');

    if (bodyCode.isNotEmpty) {
      bodyBuffer.writeln('$bodyCode,');
    }
    if (queryCode.isNotEmpty) {
      bodyBuffer.writeln('$queryCode,');
    }

    bodyBuffer.writeln(');');

    if (!isVoidReturn) {
      if (returnType.isDartCoreList) {
        final listType = _getListType(returnType);
        bodyBuffer.writeln(
          'return dson.fromJsonList<$listType>(response.data);',
        );
      } else if (returnType.isDartCoreMap) {
        bodyBuffer.writeln(
          'return response.data as ${returnType.getDisplayString()};',
        );
      } else {
        bodyBuffer.writeln('return dson.fromJson<$returnType>(response.data);');
      }
    }

    bodyBuffer.writeln('}');
  }

  bodyBuffer.writeln('}');

  return bodyBuffer.toString();
}

DartType _getFutureType(DartType type) {
  if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
    return type is InterfaceType ? type.typeArguments.first : type;
  }
  return type;
}

DartType _getListType(DartType type) {
  if (type.isDartCoreList) {
    return type is InterfaceType ? type.typeArguments.first : type;
  }
  return type;
}
