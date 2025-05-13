part of 'annotation.dart';

class McpController implements BaseComponent {
  const McpController();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

class Tool {
  final String description;
  final String? title;
  final bool? readOnlyHint;
  final bool? destructiveHint;
  final bool? idempotentHint;
  final bool? openWorldHint;

  const Tool(
    this.description, {
    this.title,
    this.readOnlyHint,
    this.destructiveHint,
    this.idempotentHint,
    this.openWorldHint,
  });
}
