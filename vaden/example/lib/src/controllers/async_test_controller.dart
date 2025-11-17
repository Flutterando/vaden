import 'dart:convert';

import 'package:example/src/services/async_test_service.dart';
import 'package:vaden/vaden.dart';

/// Controller that depends on AsyncTestService
/// This creates the dependency chain:
/// Controller -> Service -> Repository -> DatabaseConnection (async bean)
@Controller('/api/async-test')
class AsyncTestController {
  final AsyncTestService service;

  AsyncTestController(this.service);

  @Get('/')
  Future<Response> getAll(Request request) async {
    try {
      final items = await service.getAllItems();
      return Response.ok(jsonEncode({'items': items}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  @Get('/:id')
  Future<Response> getById(Request request, @Param() String id) async {
    try {
      final item = await service.getItemById(id);
      if (item == null) {
        return Response.notFound(jsonEncode({'error': 'Item not found'}));
      }
      return Response.ok(jsonEncode({'item': item}));
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }
}
