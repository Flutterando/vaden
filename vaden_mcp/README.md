# Vaden MCP Server

An **MCP (Model Context Protocol) server** for analyzing, understanding, and manipulating **Vaden** projects.

## Overview

`vaden_mcp` enables AI assistants and LLMs to interact with Vaden backend projects through the Model Context Protocol. It provides a set of tools for:

- **Project Introspection**: Scan and analyze project structure
- **Code Generation**: Create controllers, services, configurations
- **Code Mutation**: Add routes, modify existing components
- **Context Building**: Prepare detailed context for AI code generation

## Installation

### Prerequisites

- Dart SDK 3.10.0 or higher
- A Vaden project to work with

### Install from source

```bash
dart pub global activate vaden_mcp
```

## Usage

### Running the MCP Server

The MCP server communicates via JSON-RPC over stdin/stdout.

### Connecting with MCP Clients

#### Claude Desktop Example

Add to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "vaden": {
      "command": "vaden_mcp",
      "args": []
    }
  }
}
```

#### Using with other MCP clients

Any MCP-compatible client can connect to vaden_mcp using the stdio transport.
## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is part of the Vaden framework and follows the same license.

## Resources

- [Vaden Documentation](https://doc.vaden.dev)
- [Model Context Protocol](https://modelcontextprotocol.io)
- [Vaden GitHub](https://github.com/Flutterando/vaden)

## Support

- [Flutterando Discord](https://discord.flutterando.com.br)
- [GitHub Issues](https://github.com/Flutterando/vaden/issues)
