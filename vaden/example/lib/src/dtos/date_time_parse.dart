import 'package:vaden/vaden.dart';

@Parse()
class DateTimeParse extends ParamParse<DateTime?, String> {
  const DateTimeParse();

  @override
  String toJson(DateTime? param) {
    return param?.toIso8601String() ?? '';
  }

  @override
  DateTime? fromJson(String? json) {
    return DateTime.tryParse(json ?? '');
  }
}
