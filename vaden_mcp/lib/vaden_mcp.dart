/// Vaden MCP Server
///
/// An MCP (Model Context Protocol) server for analyzing, understanding,
/// and manipulating Vaden projects.
library;

// Core exports
export 'core/mcp_server.dart';
export 'core/file_utils.dart';
export 'core/project_scanner.dart';
export 'core/code_parser.dart';

// Models
export 'models/mcp_message.dart';

// Tools
export 'tools/project_tools.dart';
export 'tools/codegen_tools.dart';

// Templates
export 'templates/controller_template.dart';
export 'templates/service_template.dart';
export 'templates/configuration_template.dart';
