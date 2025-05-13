import 'package:vaden/vaden.dart';

@DTO()
class TesteMcpDto {
  final String name;
  final List<int> numList;
  TesteMcpDto({
    required this.name,
    required this.numList,
  });
}
