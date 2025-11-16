/// Templates for generating Vaden controllers
class ControllerTemplate {
  /// Generate a basic REST controller
  static String generateController({
    required String className,
    required String route,
    String? description,
    bool includeRudMethods = false,
  }) {
    final buffer = StringBuffer();

    buffer.writeln("import 'package:vaden/vaden.dart';");
    buffer.writeln();

    if (description != null) {
      buffer.writeln("@Api(tag: '${_toKebabCase(className)}', description: '$description')");
    } else {
      buffer.writeln("@Api(tag: '${_toKebabCase(className)}')");
    }

    buffer.writeln("@Controller('$route')");
    buffer.writeln('class $className {');

    if (includeRudMethods) {
      buffer.writeln(_generateCrudMethods());
    } else {
      buffer.writeln(_generateBasicMethod());
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate a basic GET method
  static String _generateBasicMethod() {
    return '''
  @Get('/')
  String hello() {
    return 'Hello from controller';
  }
''';
  }

  /// Generate CRUD methods
  static String _generateCrudMethods() {
    return '''
  @Get('/')
  List<Map<String, dynamic>> getAll() {
    // TODO: Implement getAll
    return [];
  }

  @Get('/{id}')
  Map<String, dynamic> getById(@PathVariable() int id) {
    // TODO: Implement getById
    return {};
  }

  @Post('/')
  Map<String, dynamic> create(@RequestBody() Map<String, dynamic> data) {
    // TODO: Implement create
    return data;
  }

  @Put('/{id}')
  Map<String, dynamic> update(
    @PathVariable() int id,
    @RequestBody() Map<String, dynamic> data,
  ) {
    // TODO: Implement update
    return data;
  }

  @Delete('/{id}')
  Map<String, dynamic> delete(@PathVariable() int id) {
    // TODO: Implement delete
    return {'deleted': id};
  }
''';
  }

  /// Generate a route method
  static String generateRouteMethod({
    required String httpMethod,
    required String path,
    required String methodName,
    required String returnType,
    List<Map<String, String>>? parameters,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('  @$httpMethod(\'$path\')');
    buffer.write('  $returnType $methodName(');

    if (parameters != null && parameters.isNotEmpty) {
      final params = parameters.map((p) {
        final type = p['type']!;
        final name = p['name']!;
        final annotation = p['annotation'];

        if (annotation != null) {
          return '@$annotation() $type $name';
        }
        return '$type $name';
      }).join(', ');

      buffer.write(params);
    }

    buffer.writeln(') {');
    buffer.writeln('    // TODO: Implement $methodName');

    if (returnType == 'String') {
      buffer.writeln("    return 'Response from $methodName';");
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

  /// Convert class name to kebab-case
  static String _toKebabCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '-${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('-', '');
  }
}
