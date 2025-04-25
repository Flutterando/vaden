/// Annotations for defining application components and API endpoints.
///
/// This file contains annotations for defining controllers, services, repositories,
/// and other components in a Vaden application, as well as annotations for
/// defining REST API endpoints and OpenAPI documentation.
library;

part 'openapi.dart';
part 'rest.dart';

/// Base interface for all component annotations.
///
/// This interface defines the common behavior for all component annotations
/// in the Vaden framework. It specifies whether a component should be registered
/// with its interface or supertype in the dependency injection container.
abstract interface class BaseComponent {
  /// Determines if the component should be registered with its interface or supertype.
  ///
  /// When true, the component will be registered with its interface or supertype
  /// in the dependency injection container, allowing for dependency injection
  /// by interface rather than concrete implementation.
  bool get registerWithInterfaceOrSuperType;
}

/// Marks a class as a general component in the application.
///
/// Components are general-purpose classes that can be registered in the
/// dependency injection container. Use this annotation for classes that
/// don't fit into more specific categories like Service or Repository.
///
/// Example:
/// ```dart
/// @Component()
/// class EmailFormatter {
///   String format(String email) => email.toLowerCase();
/// }
/// ```
final class Component implements BaseComponent {
  @override
  final bool registerWithInterfaceOrSuperType;

  /// Creates a Component annotation.
  ///
  /// [registerWithInterfaceOrSuperType] - When true, the component will be registered
  /// with its interface or supertype in the dependency injection container.
  /// Defaults to false.
  const Component([this.registerWithInterfaceOrSuperType = false]);
}

/// Marks a class as a service in the application.
///
/// Services contain business logic and application workflows. They typically
/// coordinate between repositories and other services to implement application features.
///
/// By default, services are registered with their interface or supertype in the
/// dependency injection container, allowing for easy mocking and testing.
///
/// Example:
/// ```dart
/// abstract class UserService {
///   Future<User> getUserById(String id);
/// }
///
/// @Service()
/// class UserServiceImpl implements UserService {
///   final UserRepository _repository;
///
///   UserServiceImpl(this._repository);
///
///   @override
///   Future<User> getUserById(String id) => _repository.findById(id);
/// }
/// ```
final class Service implements BaseComponent {
  /// Creates a Service annotation.
  ///
  /// [registerWithInterfaceOrSuperType] - When true, the service will be registered
  /// with its interface or supertype in the dependency injection container.
  /// Defaults to true for services to encourage programming to interfaces.
  const Service([this.registerWithInterfaceOrSuperType = true]);

  @override
  final bool registerWithInterfaceOrSuperType;
}

/// Marks a class as a repository in the application.
///
/// Repositories are responsible for data access and persistence operations.
/// They abstract the underlying data storage mechanism and provide a clean API
/// for services to interact with data sources.
///
/// By default, repositories are registered with their interface or supertype in the
/// dependency injection container, allowing for easy mocking and testing.
///
/// Example:
/// ```dart
/// abstract class UserRepository {
///   Future<User?> findById(String id);
///   Future<List<User>> findAll();
///   Future<void> save(User user);
/// }
///
/// @Repository()
/// class UserRepositoryImpl implements UserRepository {
///   final Database _db;
///
///   UserRepositoryImpl(this._db);
///
///   @override
///   Future<User?> findById(String id) async {
///     final result = await _db.query('users', where: 'id = ?', whereArgs: [id]);
///     return result.isEmpty ? null : User.fromMap(result.first);
///   }
///
///   // Other method implementations...
/// }
/// ```
final class Repository implements BaseComponent {
  /// Creates a Repository annotation.
  ///
  /// [registerWithInterfaceOrSuperType] - When true, the repository will be registered
  /// with its interface or supertype in the dependency injection container.
  /// Defaults to true for repositories to encourage programming to interfaces.
  const Repository([this.registerWithInterfaceOrSuperType = true]);

  @override
  final bool registerWithInterfaceOrSuperType;
}

/// Marks a class as a configuration component in the application.
///
/// Configuration classes typically contain methods annotated with @Bean
/// that create and configure application components. They are used to set up
/// external dependencies, configure application settings, and define beans.
///
/// Example:
/// ```dart
/// @Configuration()
/// class AppConfig {
///   @Bean()
///   Database createDatabase(ApplicationSettings settings) {
///     return Database.connect(settings['database_url']);
///   }
/// }
/// ```
final class Configuration implements BaseComponent {
  /// Creates a Configuration annotation.
  const Configuration();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

/// Marks a method in a Configuration class as a bean factory.
///
/// Methods annotated with @Bean are used to create and configure instances
/// of components that will be registered in the dependency injection container.
/// Bean methods can have parameters, which will be automatically injected.
///
/// Example:
/// ```dart
/// @Configuration()
/// class AppConfig {
///   @Bean()
///   HttpClient createHttpClient() {
///     return HttpClient()
///       ..connectionTimeout = const Duration(seconds: 10);
///   }
/// }
/// ```
class Bean {
  /// Creates a Bean annotation.
  const Bean();
}

/// Marks a class as a REST controller in the application.
///
/// Controllers handle incoming HTTP requests and define API endpoints. They contain
/// methods annotated with REST annotations (@Get, @Post, etc.) that map to specific
/// HTTP endpoints.
///
/// The [path] parameter defines the base path for all endpoints in the controller.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Get('/')
///   Future<Response> getAllUsers(Request request) async {
///     final users = await _service.findAll();
///     return Response.ok(jsonEncode(users));
///   }
///
///   @Get('/:id')
///   Future<Response> getUserById(Request request, String id) async {
///     final user = await _service.findById(id);
///     return user != null
///         ? Response.ok(jsonEncode(user))
///         : Response.notFound('User not found');
///   }
/// }
/// ```
final class Controller implements BaseComponent {
  /// The base path for all endpoints in this controller.
  ///
  /// This path will be prefixed to all endpoint paths defined in the controller.
  /// For example, if the controller path is '/api/users' and an endpoint path is
  /// '/:id', the full path will be '/api/users/:id'.
  final String path;

  /// Creates a Controller annotation with the specified base path.
  ///
  /// [path] - The base path for all endpoints in this controller.
  const Controller(this.path);

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

/// Marks a class as a controller advice for global exception handling.
///
/// Controller advice classes contain methods annotated with @ExceptionHandler
/// that handle specific types of exceptions thrown during request processing.
/// They provide a centralized way to handle exceptions across multiple controllers.
///
/// Example:
/// ```dart
/// @ControllerAdvice()
/// class GlobalExceptionHandler {
///   @ExceptionHandler(ValidationException)
///   Response handleValidationException(Request request, ValidationException e) {
///     return Response(400, body: jsonEncode({'error': e.message}));
///   }
///
///   @ExceptionHandler(NotFoundException)
///   Response handleNotFoundException(Request request, NotFoundException e) {
///     return Response.notFound(jsonEncode({'error': e.message}));
///   }
/// }
/// ```
final class ControllerAdvice implements BaseComponent {
  /// Creates a ControllerAdvice annotation.
  const ControllerAdvice();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

/// Marks a method in a ControllerAdvice class as an exception handler.
///
/// Methods annotated with @ExceptionHandler are used to handle specific types
/// of exceptions thrown during request processing. The method should accept
/// the exception type as a parameter and return a Response.
///
/// The [exceptionType] parameter specifies the type of exception this handler
/// will handle.
///
/// Example:
/// ```dart
/// @ControllerAdvice()
/// class GlobalExceptionHandler {
///   @ExceptionHandler(DatabaseException)
///   Response handleDatabaseException(Request request, DatabaseException e) {
///     return Response.internalServerError(
///       body: jsonEncode({'error': 'Database error', 'message': e.message})
///     );
///   }
/// }
/// ```
final class ExceptionHandler {
  /// The type of exception this handler will handle.
  final Type exceptionType;

  /// Creates an ExceptionHandler annotation for the specified exception type.
  ///
  /// [exceptionType] - The type of exception this handler will handle.
  const ExceptionHandler(this.exceptionType);
}

/// Marks a class as a Data Transfer Object (DTO).
///
/// DTOs are used to transfer data between the client and server. They define
/// the structure of request and response bodies and provide serialization and
/// deserialization capabilities through the DSON system.
///
/// Example:
/// ```dart
/// @DTO()
/// class UserDTO {
///   final String id;
///   final String name;
///   final String email;
///
///   UserDTO({required this.id, required this.name, required this.email});
///
///   factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
///     id: json['id'],
///     name: json['name'],
///     email: json['email'],
///   );
///
///   Map<String, dynamic> toJson() => {
///     'id': id,
///     'name': name,
///     'email': email,
///   };
/// }
/// ```
final class DTO implements BaseComponent {
  /// Creates a DTO annotation.
  const DTO();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

/// Specifies the JSON key name for a field in a DTO.
///
/// Use this annotation to customize the key name used in JSON serialization
/// and deserialization for a specific field.
///
/// Example:
/// ```dart
/// @DTO()
/// class UserDTO {
///   @JsonKey('user_id')
///   final String id;
///
///   final String name;
///
///   UserDTO({required this.id, required this.name});
/// }
/// ```
class JsonKey {
  /// The name to use for this field in JSON serialization/deserialization.
  final String name;

  /// Creates a JsonKey annotation with the specified name.
  ///
  /// [name] - The name to use for this field in JSON.
  const JsonKey(this.name);
}

/// Excludes a field from JSON serialization and deserialization.
///
/// Fields annotated with @JsonIgnore will be skipped during JSON serialization
/// and deserialization.
///
/// Example:
/// ```dart
/// @DTO()
/// class UserDTO {
///   final String id;
///   final String name;
///
///   @JsonIgnore()
///   final String password; // Will not be included in JSON
///
///   UserDTO({required this.id, required this.name, required this.password});
/// }
/// ```
class JsonIgnore {
  /// Creates a JsonIgnore annotation.
  const JsonIgnore();
}

/// Applies middleware to a controller or endpoint.
///
/// Middleware can be used to intercept and process requests and responses
/// before they reach the controller or after they leave it. Common use cases
/// include logging, authentication, and request transformation.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// @UseMiddleware([LoggingMiddleware])
/// class UserController {
///   // All endpoints in this controller will use LoggingMiddleware
///
///   @Get('/')
///   Future<Response> getAllUsers(Request request) { ... }
///
///   @Post('/')
///   @UseMiddleware([ValidationMiddleware])
///   // This endpoint will use both LoggingMiddleware and ValidationMiddleware
///   Future<Response> createUser(Request request) { ... }
/// }
/// ```
class UseMiddleware {
  /// The list of middleware types to apply.
  final List<Type> middlewares;

  /// Creates a UseMiddleware annotation with the specified middleware types.
  ///
  /// [middlewares] - The list of middleware types to apply.
  const UseMiddleware(this.middlewares);
}

/// Applies guards to a controller or endpoint.
///
/// Guards are special middleware that can prevent a request from being processed
/// based on certain conditions. They are commonly used for authentication and
/// authorization.
///
/// Example:
/// ```dart
/// @Controller('/api/admin')
/// @UseGuards([AuthGuard, AdminGuard])
/// class AdminController {
///   // All endpoints in this controller will be protected by AuthGuard and AdminGuard
///
///   @Get('/stats')
///   Future<Response> getStats(Request request) { ... }
///
///   @Post('/settings')
///   @UseGuards([SuperAdminGuard])
///   // This endpoint will use AuthGuard, AdminGuard, and SuperAdminGuard
///   Future<Response> updateSettings(Request request) { ... }
/// }
/// ```
class UseGuards {
  /// The list of guard types to apply.
  final List<Type> guards;

  /// Creates a UseGuards annotation with the specified guard types.
  ///
  /// [guards] - The list of guard types to apply.
  const UseGuards(this.guards);
}

/// Binds a query parameter from the request URL to a method parameter.
///
/// Use this annotation to extract query parameters from the request URL and
/// bind them to method parameters in controller endpoints.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/')
///   Future<Response> searchUsers(
///     Request request,
///     @Query('name') String? name,
///     @Query('age') int? age,
///   ) {
///     // Access query parameters directly as method parameters
///     // URL: /api/users?name=John&age=30
///     // name will be 'John', age will be 30
///     // ...
///   }
/// }
/// ```
class Query {
  /// The name of the query parameter in the URL.
  ///
  /// If null, the parameter name in the method will be used.
  final String? name;

  /// Creates a Query annotation with the specified name.
  ///
  /// [name] - The name of the query parameter in the URL.
  /// If not provided, the parameter name in the method will be used.
  const Query([this.name]);
}

/// Binds a path parameter from the request URL to a method parameter.
///
/// Use this annotation to extract path parameters from the request URL and
/// bind them to method parameters in controller endpoints.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/:id')
///   Future<Response> getUserById(
///     Request request,
///     @Param('id') String userId,
///   ) {
///     // Access path parameters directly as method parameters
///     // URL: /api/users/123
///     // userId will be '123'
///     // ...
///   }
/// }
/// ```
class Param {
  /// The name of the path parameter in the URL.
  ///
  /// If null, the parameter name in the method will be used.
  final String? name;

  /// Creates a Param annotation with the specified name.
  ///
  /// [name] - The name of the path parameter in the URL.
  /// If not provided, the parameter name in the method will be used.
  const Param([this.name]);
}

/// Binds the request body to a method parameter.
///
/// Use this annotation to extract and deserialize the request body and
/// bind it to a method parameter in controller endpoints.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Post('/')
///   Future<Response> createUser(
///     Request request,
///     @Body() UserDTO user,
///   ) {
///     // Access the deserialized request body directly as a method parameter
///     // The request body JSON will be automatically deserialized to a UserDTO
///     // ...
///   }
/// }
/// ```
class Body {
  /// Creates a Body annotation.
  const Body();
}

/// Binds a header value from the request to a method parameter.
///
/// Use this annotation to extract header values from the request and
/// bind them to method parameters in controller endpoints.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/')
///   Future<Response> getUsers(
///     Request request,
///     @Header('Authorization') String authToken,
///   ) {
///     // Access header values directly as method parameters
///     // authToken will contain the value of the Authorization header
///     // ...
///   }
/// }
/// ```
class Header {
  /// The name of the header in the request.
  final String name;

  /// Creates a Header annotation with the specified name.
  ///
  /// [name] - The name of the header in the request.
  const Header(this.name);
}

/// Binds a context value from the request to a method parameter.
///
/// Use this annotation to extract context values that have been added to the
/// request by middleware and bind them to method parameters in controller endpoints.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/')
///   Future<Response> getUsers(
///     Request request,
///     @Context('currentUser') User currentUser,
///   ) {
///     // Access context values directly as method parameters
///     // currentUser will contain the value added to the request context
///     // by an authentication middleware
///     // ...
///   }
/// }
/// ```
class Context {
  /// The name of the context value in the request.
  final String name;

  /// Creates a Context annotation with the specified name.
  ///
  /// [name] - The name of the context value in the request.
  const Context(this.name);
}

class Parse implements BaseComponent {
  const Parse();

  @override
  final bool registerWithInterfaceOrSuperType = false;
}

class UseParse {
  final Type parser;

  const UseParse(this.parser);
}

class VadenModule {
  final List<Type> imports;
  const VadenModule(this.imports);
}
