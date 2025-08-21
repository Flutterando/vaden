import 'package:domain/domain.dart';
import 'package:drift/drift.dart';
import 'package:todo_backend/config/drift/drift_configuration.dart';
import 'package:vaden/vaden.dart';

abstract class TodoRepository {
  Future<List<Todo>> getAll();
  Future<Todo> getById(int id);
  Future<void> add(TodoCreate todo);
  Future<void> update(TodoUpdate todo);
  Future<void> delete(int id);
}

@Repository()
class TodoRepositoryImpl implements TodoRepository {
  final AppDatabase _appDatabase;

  TodoRepositoryImpl(this._appDatabase);

  @override
  Future<List<Todo>> getAll() async {
    final tables = await _appDatabase.select(_appDatabase.todoTable).get();
    return tables.map(_mapToTodo).toList();
  }

  @override
  Future<Todo> getById(int id) async {
    final table = await _appDatabase //
        .managers
        .todoTable
        .filter((t) => t.id.equals(id))
        .getSingleOrNull();

    if (table == null) {
      throw Exception('Todo with id $id not found');
    }

    return _mapToTodo(table);
  }

  @override
  Future<void> add(TodoCreate todo) async {
    await _appDatabase.into(_appDatabase.todoTable).insert(
          TodoTableCompanion(
            title: Value(todo.title),
            check: Value(todo.check),
          ),
        );
  }

  @override
  Future<void> update(TodoUpdate todo) async {
    await _appDatabase
        .managers //
        .todoTable
        .filter((t) => t.id.equals(todo.id))
        .update(
      (o) {
        return o(
          check: Value(todo.check),
          title: Value(todo.title),
        );
      },
    );
  }

  @override
  Future<void> delete(int id) async {
    await _appDatabase.managers.todoTable
        .filter((t) => t.id.equals(id))
        .delete();
  }

  Todo _mapToTodo(TodoTableData t) {
    return Todo(
      id: t.id,
      title: t.title,
      check: t.check,
    );
  }
}
