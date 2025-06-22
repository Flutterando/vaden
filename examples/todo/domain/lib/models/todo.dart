import 'package:vaden_core/vaden_core.dart';

@DTO()
class Todo {
  final int id;
  final String title;
  final bool check;

  Todo({required this.id, required this.title, required this.check});
}

@DTO()
class TodoCreate {
  final String title;
  final bool check;

  TodoCreate({required this.title, required this.check});
}
