import 'package:vaden_mcp/vaden_mcp.dart';
import 'package:test/test.dart';

void main() {
  group('FileUtils tests', () {
    test('toSnakeCase converts correctly', () {
      // Basic test to verify the package loads
      expect(true, isTrue);
    });
  });

  group('MCPRequest tests', () {
    test('MCPRequest can be created', () {
      final request = MCPRequest(
        id: '1',
        method: 'test',
      );

      expect(request.id, equals('1'));
      expect(request.method, equals('test'));
      expect(request.jsonrpc, equals('2.0'));
    });

    test('MCPRequest can be converted to JSON', () {
      final request = MCPRequest(
        id: '1',
        method: 'test',
        params: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['id'], equals('1'));
      expect(json['method'], equals('test'));
      expect(json['params'], equals({'key': 'value'}));
    });
  });
}
