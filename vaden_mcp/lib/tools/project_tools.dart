import '../core/project_scanner.dart';
import '../core/code_parser.dart';
import '../core/file_utils.dart';
import '../models/mcp_message.dart';

/// MCP tools for project introspection
class ProjectTools {
  final String projectRoot;
  late final ProjectScanner _scanner;

  ProjectTools(this.projectRoot) {
    _scanner = ProjectScanner(projectRoot);
  }

  /// Get tool info for scan_project
  static MCPToolInfo get scanProjectInfo => MCPToolInfo(
        name: 'scan_project',
        description: 'Scan and analyze the Vaden project structure',
        inputSchema: {
          'type': 'object',
          'properties': {},
          'required': [],
        },
      );

  /// Scan project structure
  Future<Map<String, dynamic>> scanProject(Map<String, dynamic> params) async {
    try {
      final summary = await _scanner.getProjectSummary();
      final config = await _scanner.getApplicationConfig();

      return {
        'success': true,
        'data': {
          ...summary,
          if (config != null) 'applicationConfig': config,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for list_controllers
  static MCPToolInfo get listControllersInfo => MCPToolInfo(
        name: 'list_controllers',
        description: 'List all controllers in the Vaden project',
        inputSchema: {
          'type': 'object',
          'properties': {
            'includeDetails': {
              'type': 'boolean',
              'description': 'Include detailed route information',
              'default': false,
            },
          },
        },
      );

  /// List all controllers
  Future<Map<String, dynamic>> listControllers(
    Map<String, dynamic> params,
  ) async {
    try {
      final controllers = await _scanner.findControllers();
      final includeDetails = params['includeDetails'] as bool? ?? false;

      final controllerList = <Map<String, dynamic>>[];

      for (final controller in controllers) {
        final relativePath = FileUtils.getRelativePath(projectRoot, controller);
        final classInfo = await CodeParser.extractClassInfo(controller);

        final controllerData = <String, dynamic>{
          'path': relativePath,
          'absolutePath': controller,
        };

        if (includeDetails && classInfo != null) {
          controllerData['className'] = classInfo.name;
          controllerData['annotations'] = classInfo.annotations;

          final routes = await CodeParser.extractRoutes(controller);
          controllerData['routes'] = routes.map((r) => r.toJson()).toList();
        }

        controllerList.add(controllerData);
      }

      return {
        'success': true,
        'count': controllerList.length,
        'controllers': controllerList,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for list_services
  static MCPToolInfo get listServicesInfo => MCPToolInfo(
        name: 'list_services',
        description: 'List all services in the Vaden project',
        inputSchema: {
          'type': 'object',
          'properties': {},
        },
      );

  /// List all services
  Future<Map<String, dynamic>> listServices(Map<String, dynamic> params) async {
    try {
      final services = await _scanner.findServices();

      final serviceList = services
          .map((s) => {
                'path': FileUtils.getRelativePath(projectRoot, s),
                'absolutePath': s,
              })
          .toList();

      return {
        'success': true,
        'count': serviceList.length,
        'services': serviceList,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for list_repositories
  static MCPToolInfo get listRepositoriesInfo => MCPToolInfo(
        name: 'list_repositories',
        description: 'List all repositories in the Vaden project',
        inputSchema: {
          'type': 'object',
          'properties': {},
        },
      );

  /// List all repositories
  Future<Map<String, dynamic>> listRepositories(
    Map<String, dynamic> params,
  ) async {
    try {
      final repositories = await _scanner.findRepositories();

      final repositoryList = repositories
          .map((r) => {
                'path': FileUtils.getRelativePath(projectRoot, r),
                'absolutePath': r,
              })
          .toList();

      return {
        'success': true,
        'count': repositoryList.length,
        'repositories': repositoryList,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for list_modules
  static MCPToolInfo get listModulesInfo => MCPToolInfo(
        name: 'list_modules',
        description: 'List all modules in the Vaden project',
        inputSchema: {
          'type': 'object',
          'properties': {},
        },
      );

  /// List all modules
  Future<Map<String, dynamic>> listModules(Map<String, dynamic> params) async {
    try {
      final modules = await _scanner.findModules();

      final moduleList = modules
          .map((m) => {
                'path': FileUtils.getRelativePath(projectRoot, m),
                'absolutePath': m,
              })
          .toList();

      return {
        'success': true,
        'count': moduleList.length,
        'modules': moduleList,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for get_configuration
  static MCPToolInfo get getConfigurationInfo => MCPToolInfo(
        name: 'get_configuration',
        description: 'Get application.yaml configuration',
        inputSchema: {
          'type': 'object',
          'properties': {},
        },
      );

  /// Get configuration
  Future<Map<String, dynamic>> getConfiguration(
    Map<String, dynamic> params,
  ) async {
    try {
      final config = await _scanner.getApplicationConfig();

      if (config == null) {
        return {
          'success': false,
          'error': 'application.yaml not found',
        };
      }

      return {
        'success': true,
        'configuration': config,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get tool info for validate_vaden_project
  static MCPToolInfo get validateProjectInfo => MCPToolInfo(
        name: 'validate_vaden_project',
        description: 'Validate if current directory is a valid Vaden project',
        inputSchema: {
          'type': 'object',
          'properties': {},
        },
      );

  /// Validate Vaden project
  Future<Map<String, dynamic>> validateProject(
    Map<String, dynamic> params,
  ) async {
    try {
      final isValid = await _scanner.isVadenProject();
      final projectName = await _scanner.getProjectName();

      return {
        'success': true,
        'isVadenProject': isValid,
        'projectName': projectName,
        'projectRoot': projectRoot,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
