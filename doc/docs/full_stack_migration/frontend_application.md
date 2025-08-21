---
sidebar_position: 4
---

# The `Frontend` (Flutter App)

The frontend is a standard Flutter application that communicates with the backend. This section details how to integrate and utilize the `flutter_vaden` package to streamline development, focusing on dependency injection and API client generation.

## Vaden Setup

The `flutter_vaden` package integrates Vaden's dependency injection and other services into your Flutter app.

### Installation

To get started, add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_vaden: ^latest_version # Use the latest version
  dio: ^latest_version # Dio is used internally by @ApiClient

dev_dependencies:
  vaden_class_scanner: ^latest_version # Use the latest version
  build_runner: ^latest_version # Required for code generation
```

Run `flutter pub get` to install the dependencies.

### Code Generation

Vaden relies on code generation to set up its dependency injection and API clients. Create a `build.yaml` file in the root of your project with the following content:

```yaml
targets:
  $default:
    builders:
      vaden_class_scanner|aggregating_vaden_builder:
        enabled: true
        options:
          target: flutter
```

Then, run the code generator:

```bash
dart run build_runner build
```

This command will generate a file (typically `lib/vaden_application.dart` or similar, depending on your project structure) that includes a class named `VadenApp`.

### The `VadenApp` Widget

The generated `VadenApp` class extends `FlutterVadenApplication` and is your application's entry point for Vaden's services. You should use this generated `VadenApp` in your `runApp` method.

```dart
void main() {
  runApp(VadenApp(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

### The Application Module

Next, you define a main module for your Flutter application. This module, annotated with `@VadenModule`, is where you list all the other modules that your application depends on. This typically includes a shared `DomainModule` (if you have one) and any frontend-specific configuration modules.

```dart
@VadenModule([DomainModule, AppConfig])
class AppModule {}
```

## Dependency Injection

`flutter_vaden` provides a robust dependency injection system.

- `@Configuration()`: Used to define configuration classes that provide instances of objects.
- `@Bean()`: Marks a method within a `@Configuration()` class that provides an instance to the injector.
- `@Service()`: Marks classes as services. Prefer registering services via their interfaces.
- `@Repository()`: Marks classes as repositories. Prefer registering repositories via their interfaces.
- `@Component()`: Marks any class that needs to be registered in the dependency injection system.

### Accessing Instances in Widgets

You can access registered instances directly in your Flutter widgets using the `context.read<T>()` extension method.

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Access a service or API client
    final myService = context.read<MyService>();
    // ... use myService
    return Container();
  }
}
```

## Connecting Frontend to Backend with `@ApiClient()`

`flutter_vaden` simplifies API interactions using the `@ApiClient()` annotation, which generates an API client based on an abstract class.

### 1. Configure HTTP Client Package

First, create a configuration class to provide and configure your client package instance. This is where you set the `baseUrl` and add any interceptors. In this example we will use `Dio` as the HTTp client.

```dart
@Configuration()
class DioConfiguration {
  @Bean()
  Dio dio() {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'));
    dio.interceptors.add(LogInterceptor(responseBody: true)); // Example interceptor
    return dio;
  }
}
```

Make sure to include `DioConfiguration` in your `AppModule` if it's not already part of another imported module.

### 2. Define Your API Client

Create an abstract class annotated with `@ApiClient()` to define your API endpoints. Vaden's code generator will create an implementation for this interface.

```dart
@ApiClient()
abstract class TodoApi {
  @Get('/todos')
  Future<List<TodoModel>> getAllTodos();

  @Post('/todos')
  Future<TodoModel> createTodo(@Body() TodoModel todo);

  @Put('/todos/{id}')
  Future<TodoModel> updateTodo(@Param('id') String id, @Body() TodoModel todo);

  @Delete('/todos/{id}')
  Future<void> deleteTodo(@Param('id') String id);
}
```

**Note:** All DTOs (Data Transfer Objects) used as return types or `@Body()` parameters in your `@ApiClient()` methods must be annotated with `@DTO()` within your domain package.

### 3. Use the API Client in Your UI

Finally, inject and use your generated API client in your Flutter widgets.

```dart
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPagen> {
  late final TodoApi _todoApi;
  late Future<List<TodoModel>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _todoApi = context.read<TodoApi>(); // Inject the API client
    _loadTodos();
  }

  void _loadTodos() {
    setState(() {
      _todosFuture = _todoApi.getAllTodos();
    });
  }

  Future<void> _addTodo() async {
    // Example: create a new todo
    final newTodo = TodoModel(id: UniqueKey().toString(), title: 'New Task', completed: false);
    await _todoApi.createTodo(newTodo);
    _loadTodos(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    //return ...
  }
}
```
