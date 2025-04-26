import 'dart:convert';

import 'package:example/vaden_application.dart';
import 'package:test/test.dart';
import 'package:vaden/vaden_openapi.dart';

void main() {
  test('vaden application ...', () async {
    final app = VadenApplicationImpl();

    await app.setup();

    final open = app.injector.get<OpenApi>();

    print(jsonEncode(open.toJson()));
  });
}
