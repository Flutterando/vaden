import 'package:vaden_core/vaden_core.dart';

@DTO()
class A {
  final String id; // required
  @JsonKey('alias_optional', required: false)
  final String alias; // optional non-nullable
  final String? note; // nullable optional
  A({required this.id, required this.alias, this.note});
}

@DTO()
class B {
  @JsonKey('forced', required: true)
  final String forced; // explicitly required
  B(this.forced);
}

@DTO()
class C {
  @JsonDefault('x')
  @JsonKey('alias_c', required: false)
  final String name; // default x when missing
  final String? desc; // nullable
  C({required this.name, this.desc});
}
