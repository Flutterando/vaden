import 'package:vaden/vaden.dart';

@DTO()
class PrimitiveListDto {
  final String id;
  final List<int> numList;
  final List<String> textList;
  final List<String>? nullTextList;
  final List<PrimitiveListDto> dtoList;

  PrimitiveListDto({
    required this.id,
    required this.numList,
    required this.textList,
    this.nullTextList,
    required this.dtoList,
  });
}
