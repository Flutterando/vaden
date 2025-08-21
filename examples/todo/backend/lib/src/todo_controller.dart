import 'package:domain/models/default_message.dart';
import 'package:domain/models/todo.dart';
import 'package:todo_backend/src/todo_repository.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'todos', description: 'Todo management API')
@Controller('/todos')
class TodoController {
  final TodoRepository _todoRepository;
  TodoController(this._todoRepository);

  @Get('/')
  Future<List<Todo>> getAll() async {
    return _todoRepository.getAll();
  }

  @Get('/<id>')
  Future<Todo> getById(@Param() int id) async {
    return _todoRepository.getById(id);
  }

  @Post('/')
  Future<DefaultMessage> add(@Body() TodoCreate todo) async {
    await _todoRepository.add(todo);
    return DefaultMessage(message: 'Todo added successfully');
  }

  @Put('/<id>')
  Future<DefaultMessage> update(@Body() TodoUpdate todo) async {
    await _todoRepository.update(todo);
    return DefaultMessage(message: 'Todo updated successfully');
  }

  @Delete('/<id>')
  Future<DefaultMessage> delete(@Param() int id) async {
    await _todoRepository.delete(id);
    return DefaultMessage(message: 'Todo deleted successfully');
  }
}
