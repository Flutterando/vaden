import 'dart:io';
import 'package:vaden_mcp/core/mcp_server.dart';
import 'package:vaden_mcp/tools/project_tools.dart';
import 'package:vaden_mcp/tools/codegen_tools.dart';

/// Main entry point for the Vaden MCP server
Future<void> main(List<String> args) async {
  // Get project root from arguments or use current directory
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  // Create MCP server
  final server = MCPServer(
    serverName: 'vaden-mcp',
    serverVersion: '1.0.0',
  );

  // Initialize tools
  final projectTools = ProjectTools(projectRoot);
  final codegenTools = CodegenTools(projectRoot);

  // Register project introspection tools
  server.registerTool(
    'scan_project',
    projectTools.scanProject,
    ProjectTools.scanProjectInfo,
  );

  server.registerTool(
    'list_controllers',
    projectTools.listControllers,
    ProjectTools.listControllersInfo,
  );

  server.registerTool(
    'list_services',
    projectTools.listServices,
    ProjectTools.listServicesInfo,
  );

  server.registerTool(
    'list_repositories',
    projectTools.listRepositories,
    ProjectTools.listRepositoriesInfo,
  );

  server.registerTool(
    'list_modules',
    projectTools.listModules,
    ProjectTools.listModulesInfo,
  );

  server.registerTool(
    'get_configuration',
    projectTools.getConfiguration,
    ProjectTools.getConfigurationInfo,
  );

  server.registerTool(
    'validate_vaden_project',
    projectTools.validateProject,
    ProjectTools.validateProjectInfo,
  );

  // Register code generation tools
  server.registerTool(
    'create_controller',
    codegenTools.createController,
    CodegenTools.createControllerInfo,
  );

  server.registerTool(
    'add_route_to_controller',
    codegenTools.addRouteToController,
    CodegenTools.addRouteInfo,
  );

  server.registerTool(
    'create_configuration',
    codegenTools.createConfiguration,
    CodegenTools.createConfigurationInfo,
  );

  // Start the server
  try {
    await server.start();
  } catch (e, stack) {
    stderr.writeln('Fatal error: $e');
    stderr.writeln(stack);
    exit(1);
  }
}
