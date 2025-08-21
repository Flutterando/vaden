---
sidebar_position: 3
---

# The `Backend` Application

The backend is a standard Dart server application powered by Vaden. The project can be easily initialized using the available generator, and the complete documentation is available in the "Basic Usage" section.

## Key Configurations

- **`application.yaml`**: Configures server port, database, security, and OpenAPI settings.
- **`lib/app_module.dart`**: The main module, which imports other necessary modules like `DomainModule` and `VadenSecurity`.
- **`lib/config/`**: This directory contains detailed configurations:
  - `drift_configuration.dart`: Sets up the database using the Drift ORM. It defines the tables (e.g., `TodoTable`).
  - `security_configuration.dart`: Configures JWT settings, password encoding, and HTTP security rules (e.g., which routes are public and which require authentication).
  - `openapi_configuration.dart`: Configures the auto-generated API documentation with Swagger.

### Repository Pattern

Data access is handled using the repository pattern. An abstract class defines the contract, and a concrete class provides the implementation.

```dart
abstract class TodoRepository {
  Future<List<Todo>> getAll();
  Future<Todo> getById(int id);
  Future<void> add(TodoCreate todo);
  // ... other methods
}
```

```dart
@Repository()
class TodoRepositoryImpl implements TodoRepository {
  final AppDatabase _appDatabase;

  TodoRepositoryImpl(this._appDatabase);

  @override
  Future<List<Todo>> getAll() async {
    final tables = await _appDatabase.select(_appDatabase.todoTable).get();
    return tables.map(_mapToTodo).toList();
  }

  // ... other implementations
}
```

### REST Controller

Controllers handle incoming HTTP requests. Annotations like `@Controller`, `@Get`, `@Post`, `@Put`, and `@Delete` are used to define endpoints.

```dart
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

  // ... other endpoints
}
```

Vaden automatically injects the `TodoRepository` and handles JSON serialization/deserialization for the request body (`@Body`) and the response.
