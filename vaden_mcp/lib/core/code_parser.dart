import 'file_utils.dart';

/// Parser for extracting information from Vaden Dart code
class CodeParser {
  /// Extract class information from a Dart file
  static Future<ClassInfo?> extractClassInfo(String filePath) async {
    try {
      final content = await FileUtils.readFile(filePath);
      return _parseClassInfo(content);
    } catch (e) {
      return null;
    }
  }

  /// Parse class information from content
  static ClassInfo? _parseClassInfo(String content) {
    // Simple regex-based parsing (for production, use analyzer package)
    final classPattern = RegExp(
      r'class\s+(\w+)(?:\s+extends\s+(\w+))?(?:\s+implements\s+([\w,\s]+))?',
    );

    final match = classPattern.firstMatch(content);
    if (match == null) return null;

    final className = match.group(1)!;
    final extendsClass = match.group(2);
    final implements = match.group(3)?.split(',').map((e) => e.trim()).toList();

    // Extract annotations
    final annotations = _extractAnnotations(content, className);

    // Extract methods
    final methods = _extractMethods(content);

    return ClassInfo(
      name: className,
      extendsClass: extendsClass,
      implements: implements ?? [],
      annotations: annotations,
      methods: methods,
    );
  }

  /// Extract annotations before a class
  static List<String> _extractAnnotations(String content, String className) {
    final annotations = <String>[];
    final lines = content.split('\n');

    int classLineIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('class $className')) {
        classLineIndex = i;
        break;
      }
    }

    if (classLineIndex == -1) return annotations;

    // Look backwards for annotations
    for (int i = classLineIndex - 1; i >= 0; i--) {
      final line = lines[i].trim();
      if (line.startsWith('@')) {
        annotations.insert(0, line);
      } else if (line.isNotEmpty && !line.startsWith('//')) {
        break;
      }
    }

    return annotations;
  }

  /// Extract method information from content
  static List<MethodInfo> _extractMethods(String content) {
    final methods = <MethodInfo>[];

    // Pattern for method annotations and signatures
    final methodPattern = RegExp(
      r'@(\w+)\([^\)]*\)\s+(?:Future<)?(\w+)(?:>)?\s+(\w+)\s*\(',
      multiLine: true,
    );

    for (final match in methodPattern.allMatches(content)) {
      final annotation = match.group(1)!;
      final returnType = match.group(2)!;
      final methodName = match.group(3)!;

      methods.add(MethodInfo(
        name: methodName,
        annotation: annotation,
        returnType: returnType,
      ));
    }

    return methods;
  }

  /// Extract route information from a controller
  static Future<List<RouteInfo>> extractRoutes(String filePath) async {
    try {
      final content = await FileUtils.readFile(filePath);
      return _parseRoutes(content);
    } catch (e) {
      return [];
    }
  }

  /// Parse route information from content
  static List<RouteInfo> _parseRoutes(String content) {
    final routes = <RouteInfo>[];

    // Extract controller base path
    final controllerPattern = RegExp(r'@Controller\(["\047]([^"\047]*)["\047]');
    final controllerMatch = controllerPattern.firstMatch(content);
    final basePath = controllerMatch?.group(1) ?? '';

    // Extract route methods
    final routePattern = RegExp(
      r'@(Get|Post|Put|Delete|Patch)\(["\047]?([^"\047]*)["\047]?\)\s+(?:Future<)?(\w+)(?:>)?\s+(\w+)\s*\(([^\)]*)\)',
      multiLine: true,
    );

    for (final match in routePattern.allMatches(content)) {
      final method = match.group(1)!;
      final path = match.group(2) ?? '';
      final returnType = match.group(3)!;
      final methodName = match.group(4)!;
      final params = match.group(5)!;

      routes.add(RouteInfo(
        method: method.toUpperCase(),
        path: _combinePaths(basePath, path),
        methodName: methodName,
        returnType: returnType,
        parameters: _parseParameters(params),
      ));
    }

    return routes;
  }

  /// Combine base path and route path
  static String _combinePaths(String base, String route) {
    if (base.isEmpty) return route;
    if (route.isEmpty) return base;

    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanRoute = route.startsWith('/') ? route : '/$route';

    return cleanBase + cleanRoute;
  }

  /// Parse method parameters
  static List<ParameterInfo> _parseParameters(String params) {
    if (params.trim().isEmpty) return [];

    final parameters = <ParameterInfo>[];
    final paramList = params.split(',');

    for (final param in paramList) {
      final trimmed = param.trim();
      if (trimmed.isEmpty) continue;

      // Simple parsing: "Type name" or "Type? name"
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final type = parts[0];
        final name = parts[1];

        // Check for annotations
        String? annotation;
        if (trimmed.contains('@PathVariable')) {
          annotation = 'PathVariable';
        } else if (trimmed.contains('@RequestBody')) {
          annotation = 'RequestBody';
        } else if (trimmed.contains('@RequestParam')) {
          annotation = 'RequestParam';
        }

        parameters.add(ParameterInfo(
          type: type,
          name: name,
          annotation: annotation,
        ));
      }
    }

    return parameters;
  }

  /// Extract imports from a file
  static Future<List<String>> extractImports(String filePath) async {
    try {
      final content = await FileUtils.readFile(filePath);
      final importPattern = RegExp(r'import\s+["\047]([^"\047]+)["\047]');
      return importPattern
          .allMatches(content)
          .map((m) => m.group(1)!)
          .toList();
    } catch (e) {
      return [];
    }
  }
}

/// Information about a class
class ClassInfo {
  final String name;
  final String? extendsClass;
  final List<String> implements;
  final List<String> annotations;
  final List<MethodInfo> methods;

  ClassInfo({
    required this.name,
    this.extendsClass,
    required this.implements,
    required this.annotations,
    required this.methods,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extends': extendsClass,
      'implements': implements,
      'annotations': annotations,
      'methods': methods.map((m) => m.toJson()).toList(),
    };
  }
}

/// Information about a method
class MethodInfo {
  final String name;
  final String annotation;
  final String returnType;

  MethodInfo({
    required this.name,
    required this.annotation,
    required this.returnType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'annotation': annotation,
      'returnType': returnType,
    };
  }
}

/// Information about a route
class RouteInfo {
  final String method;
  final String path;
  final String methodName;
  final String returnType;
  final List<ParameterInfo> parameters;

  RouteInfo({
    required this.method,
    required this.path,
    required this.methodName,
    required this.returnType,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'path': path,
      'methodName': methodName,
      'returnType': returnType,
      'parameters': parameters.map((p) => p.toJson()).toList(),
    };
  }
}

/// Information about a parameter
class ParameterInfo {
  final String type;
  final String name;
  final String? annotation;

  ParameterInfo({
    required this.type,
    required this.name,
    this.annotation,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      if (annotation != null) 'annotation': annotation,
    };
  }
}
