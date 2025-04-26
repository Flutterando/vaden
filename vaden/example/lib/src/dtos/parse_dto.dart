import 'package:example/src/dtos/date_time_parse.dart';
import 'package:vaden/vaden.dart';

@DTO()
class ParseDto {
  final String id;

  @UseParse(DateTimeParse)
  final DateTime createdAt;

  @UseParse(DateTimeParse)
  final DateTime? updatedAt;

  ParseDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
}
