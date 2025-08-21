import 'package:vaden_core/vaden_core.dart';

@DTO()
sealed class Todo {
  factory Todo({required int id, required String title, required bool check}) =
      TodoBase;

  factory Todo.create({required String title, required bool check}) =
      TodoCreate;

  factory Todo.update(int id, {String title, bool check}) = TodoUpdate;
}

@DTO()
class TodoBase implements Todo {
  final int id;
  final String title;
  final bool check;

  const TodoBase({required this.id, required this.title, required this.check});

  TodoUpdate toUpdate() {
    return TodoUpdate(id, title: title, check: check);
  }
}

@DTO()
class TodoCreate implements Todo {
  final String title;
  final bool check;

  const TodoCreate({required this.title, required this.check});
}

@DTO()
class TodoUpdate implements Todo {
  final int id;
  String title;
  bool check;

  TodoUpdate(this.id, {this.title = '', this.check = false});
}
