import 'dart:convert';

import 'package:example/src/ai/teste_dto.dart';
import 'package:vaden/vaden.dart';

import 'teste_service.dart';

@McpController()
class TesteMCP {
  final DSON dson;
  final TesteMcpService service;
  TesteMCP({
    required this.dson,
    required this.service,
  });

  final String teste = 'teste';

  @Tool(
    "Get a boolean from service",
    title: 'Teste a boolean',
    readOnlyHint: false,
  )
  String getBool() {
    return 'Is ${service.isTrue()}';
  }

  @Tool(
    "Get a future boolean from service",
  )
  Future<String> getFutureBool(int seconds) async {
    final bool = await service.isFutureTrue(seconds);

    return 'Is $bool after $seconds seconds';
  }

  @Tool(
    "have a param list",
  )
  String getList(List<int> nunList) {
    return 'Nuber in the lists is ${nunList.map((e) => 'e, ')}';
  }

  @Tool("Returns the json of the DTO")
  Future<String> returnsDto(TesteMcpDto dto) async {
    final dtoJson = dson.toJson<TesteMcpDto>(dto);

    return jsonEncode(dtoJson);
  }
}
