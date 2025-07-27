import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden_core/vaden_core.dart';

final beanChecker = TypeChecker.fromRuntime(Bean);
final configurationChecker = TypeChecker.fromRuntime(Configuration);

String configurationSetup(ClassElement classElement) {
  final bodyBuffer = StringBuffer();

  final instanceName = 'configuration${classElement.name}';

  for (final method in classElement.methods) {
    if (!beanChecker.hasAnnotationOf(method)) {
      continue;
    }

    if (method.returnType.isDartAsyncFuture ||
        method.returnType.isDartAsyncFutureOr) {
      final parametersCode = method.parameters.map((param) {
        if (param.isNamed) {
          return '${param.name}: _injector()';
        }
        return '_injector()';
      }).join(', ');

      bodyBuffer.writeln('''
 _injector.commit();
final ${method.name} = await $instanceName.${method.name}($parametersCode);
 _injector.uncommit();
_injector.addInstance(${method.name});

''');
    } else {
      bodyBuffer.writeln(
          '    _injector.addLazySingleton($instanceName.${method.name});');
    }
  }

  if (bodyBuffer.isNotEmpty) {
    return '''final $instanceName = ${classElement.name}();

${bodyBuffer.toString()}
''';
  }

  return '';
}
