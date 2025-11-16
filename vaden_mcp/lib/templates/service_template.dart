/// Templates for generating Vaden services
class ServiceTemplate {
  /// Generate a basic service
  static String generateService({
    required String className,
    String? description,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("import 'package:vaden/vaden.dart';");
    buffer.writeln();

    buffer.writeln('@Service');
    buffer.writeln('class $className {');
    buffer.writeln('  $className();');
    buffer.writeln();
    buffer.writeln('  // Add your business logic methods here');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate a service method
  static String generateServiceMethod({
    required String methodName,
    required String returnType,
    List<Map<String, String>>? parameters,
  }) {
    final buffer = StringBuffer();

    buffer.write('  $returnType $methodName(');

    if (parameters != null && parameters.isNotEmpty) {
      final params = parameters
          .map((p) => '${p['type']} ${p['name']}')
          .join(', ');
      buffer.write(params);
    }

    buffer.writeln(') {');
    buffer.writeln('    // TODO: Implement $methodName');

    if (returnType == 'String') {
      buffer.writeln("    return 'Result from $methodName';");
    } else if (returnType.startsWith('List')) {
      buffer.writeln('    return [];');
    } else if (returnType.startsWith('Map')) {
      buffer.writeln('    return {};');
    } else if (returnType == 'void') {
      buffer.writeln('    // Implementation here');
    } else {
      buffer.writeln('    throw UnimplementedError();');
    }

    buffer.writeln('  }');

    return buffer.toString();
  }
}
