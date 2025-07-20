import 'package:vaden/vaden.dart';

@DTO()
class ParseDto {
  final String id;

  final DateTime createdAt;

  final DateTime? updatedAt;

  ParseDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
}
