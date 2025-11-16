import 'package:path/path.dart' as p;
import '../core/file_utils.dart';
import '../templates/controller_template.dart';
import '../templates/configuration_template.dart';
import '../models/mcp_message.dart';

/// MCP tools for code generation and mutation
class CodegenTools {
  final String projectRoot;

  CodegenTools(this.projectRoot);

  /// Get tool info for create_controller
  static MCPToolInfo get createControllerInfo => MCPToolInfo(
        name: 'create_controller',
        description: 'Create a new Vaden controller',
        inputSchema: {
          'type': 'object',
          'properties': {
            'className': {
              'type': 'string',
              'description': 'Name of the controller class (e.g., UserController)',
            },
            'route': {
              'type': 'string',
              'description': 'Base route path (e.g., /users)',
            },
            'description': {
              'type': 'string',
              'description': 'API description for OpenAPI',
            },
            'includeCRUD': {
              'type': 'boolean',
              'description': 'Include CRUD methods',
              'default': false,
            },
            'filePath': {
              'type': 'string',
              'description':
                  'Optional custom file path (relative to lib/src/controllers)',
            },
          },
          'required': ['className', 'route'],
        },
      );

  /// Create a new controller
  Future<Map<String, dynamic>> createController(
    Map<String, dynamic> params,
  ) async {
    try {
      final className = params['className'] as String;
      final route = params['route'] as String;
      final description = params['description'] as String?;
      final includeCRUD = params['includeCRUD'] as bool? ?? false;
      final customPath = params['filePath'] as String?;

      // Generate controller code
      final code = ControllerTemplate.generateController(
        className: className,
        route: route,
        description: description,
        includeRudMethods: includeCRUD,
      );

      // Determine file path
      final fileName = '${_toSnakeCase(className)}.dart';
      final filePath = customPath ??
          p.join(projectRoot, 'lib', 'src', 'controllers', fileName);

      // Ensure directory exists
      await FileUtils.ensureDirectory(p.dirname(filePath));

      // Check if file exists
      if (await FileUtils.fileExists(filePath)) {
        return {
          'success': false,
          'error': 'File already exists: $filePath',
        };
      }

      // Write file
      await FileUtils.writeFile(filePath, code);

      return {
        'success': true,
        'message': 'Controller created successfully',
        'filePath': FileUtils.getRelativePath(projectRoot, filePath),
        'absolutePath': filePath,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for add_route_to_controller
  static MCPToolInfo get addRouteInfo => MCPToolInfo(
        name: 'add_route_to_controller',
        description: 'Add a new route method to an existing controller',
        inputSchema: {
          'type': 'object',
          'properties': {
            'controllerPath': {
              'type': 'string',
              'description': 'Path to the controller file',
            },
            'httpMethod': {
              'type': 'string',
              'enum': ['Get', 'Post', 'Put', 'Delete', 'Patch'],
              'description': 'HTTP method',
            },
            'path': {
              'type': 'string',
              'description': 'Route path',
            },
            'methodName': {
              'type': 'string',
              'description': 'Name of the method',
            },
            'returnType': {
              'type': 'string',
              'description': 'Return type (e.g., String, Map<String, dynamic>)',
              'default': 'String',
            },
          },
          'required': ['controllerPath', 'httpMethod', 'path', 'methodName'],
        },
      );

  /// Add route to existing controller
  Future<Map<String, dynamic>> addRouteToController(
    Map<String, dynamic> params,
  ) async {
    try {
      final controllerPath = params['controllerPath'] as String;
      final httpMethod = params['httpMethod'] as String;
      final path = params['path'] as String;
      final methodName = params['methodName'] as String;
      final returnType = params['returnType'] as String? ?? 'String';

      final fullPath = p.isAbsolute(controllerPath)
          ? controllerPath
          : p.join(projectRoot, controllerPath);

      if (!await FileUtils.fileExists(fullPath)) {
        return {
          'success': false,
          'error': 'Controller file not found: $fullPath',
        };
      }

      // Generate route method
      final methodCode = ControllerTemplate.generateRouteMethod(
        httpMethod: httpMethod,
        path: path,
        methodName: methodName,
        returnType: returnType,
      );

      // Read current content
      final content = await FileUtils.readFile(fullPath);
      final lines = content.split('\n');

      // Find the last method or the closing brace
      int insertIndex = lines.length - 1;
      for (int i = lines.length - 1; i >= 0; i--) {
        if (lines[i].trim() == '}') {
          insertIndex = i;
          break;
        }
      }

      // Insert the new method
      lines.insert(insertIndex, methodCode);

      // Write back
      await FileUtils.writeFile(fullPath, lines.join('\n'));

      return {
        'success': true,
        'message': 'Route added successfully',
        'method': methodName,
        'path': path,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for create_configuration
  static MCPToolInfo get createConfigurationInfo => MCPToolInfo(
        name: 'create_configuration',
        description: 'Create a new Vaden configuration class',
        inputSchema: {
          'type': 'object',
          'properties': {
            'className': {
              'type': 'string',
              'description': 'Name of the configuration class',
            },
            'type': {
              'type': 'string',
              'enum': ['generic', 'openapi', 'database', 'security'],
              'description': 'Type of configuration',
              'default': 'generic',
            },
            'filePath': {
              'type': 'string',
              'description': 'Optional custom file path (relative to lib/config)',
            },
          },
          'required': ['className'],
        },
      );

  /// Create configuration
  Future<Map<String, dynamic>> createConfiguration(
    Map<String, dynamic> params,
  ) async {
    try {
      final className = params['className'] as String;
      final type = params['type'] as String? ?? 'generic';
      final customPath = params['filePath'] as String?;

      // Generate configuration code based on type
      String code;
      switch (type) {
        case 'openapi':
          code = ConfigurationTemplate.generateOpenApiConfiguration();
          break;
        case 'database':
          code = ConfigurationTemplate.generateDatabaseConfiguration();
          break;
        case 'security':
          code = ConfigurationTemplate.generateSecurityConfiguration();
          break;
        default:
          code = ConfigurationTemplate.generateConfiguration(
            className: className,
          );
      }

      // Determine file path
      final fileName = '${_toSnakeCase(className)}.dart';
      final filePath =
          customPath ?? p.join(projectRoot, 'lib', 'config', fileName);

      // Ensure directory exists
      await FileUtils.ensureDirectory(p.dirname(filePath));

      // Check if file exists
      if (await FileUtils.fileExists(filePath)) {
        return {
          'success': false,
          'error': 'File already exists: $filePath',
        };
      }

      // Write file
      await FileUtils.writeFile(filePath, code);

      return {
        'success': true,
        'message': 'Configuration created successfully',
        'filePath': FileUtils.getRelativePath(projectRoot, filePath),
        'absolutePath': filePath,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Convert string to snake_case
  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }
}
