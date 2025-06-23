import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden_core/vaden_core.dart';

final exceptionHandlerChecker = TypeChecker.fromRuntime(ExceptionHandler);
final controllerAdviceChecker = TypeChecker.fromRuntime(ControllerAdvice);

(String, Set<String>) controllerAdviceSetup(ClassElement classElement) {
  final bodyBuffer = StringBuffer();
  final Set<String> imports = {};

  final methods = classElement.methods.where((method) {
    return exceptionHandlerChecker.hasAnnotationOf(method);
  }).toList();

  if (methods.isEmpty) return ('', {});

  final instanceName = 'controllerAdvice${classElement.name}';
  bodyBuffer
      .writeln('final $instanceName = _injector.get<${classElement.name}>();');

  for (final method in methods) {
    final exceptionHandler = exceptionHandlerChecker.firstAnnotationOf(method)!;
    final exceptionType =
        exceptionHandler.getField('exceptionType')!.toTypeValue()!;
    final exceptionTypeName = _removeGeneric(exceptionType.getDisplayString());

    final import = exceptionType.element?.library?.source.uri.toString();

    if (import != null && _importNeeded(import)) {
      imports.add("'$import' show $exceptionTypeName;");
    }

    final isFuture = method.returnType.isDartAsyncFuture ||
        method.returnType.isDartAsyncFutureOr;
    bodyBuffer.writeln('''
if (e is $exceptionTypeName) {
  return ${isFuture ? 'await' : ''} $instanceName.${method.name}(e);
}
''');
  }

  return (bodyBuffer.toString(), imports);
}

String _removeGeneric(String type) {
  final index = type.indexOf('<');
  if (index == -1) return type;

  return type.substring(0, index);
}

bool _importNeeded(String import) {
  if (import.contains('dart:')) {
    return false;
  } else if (import.contains('package:vaden')) {
    return false;
  }

  return true;
}
