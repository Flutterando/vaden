import 'package:vaden_mcp/vaden_mcp.dart';

/// Example usage of Vaden MCP
void main() async {
  // Example: Scan a Vaden project
  final scanner = ProjectScanner('/path/to/vaden/project');

  final isVaden = await scanner.isVadenProject();
  print('Is Vaden project: $isVaden');

  if (isVaden) {
    final summary = await scanner.getProjectSummary();
    print('Project summary: $summary');
  }
}
