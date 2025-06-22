part of 'annotation.dart';

/// Marks a method as a handler for HTTP GET requests.
///
/// Use this annotation on controller methods to map them to HTTP GET endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Get('/') // Maps to GET /api/users/
///   Future<Response> getAllUsers(Request request) async {
///     final users = await _service.findAll();
///     return Response.ok(jsonEncode(users));
///   }
///
///   @Get('/:id') // Maps to GET /api/users/:id
///   Future<Response> getUserById(Request request, @Param('id') String id) async {
///     final user = await _service.findById(id);
///     return user != null
///         ? Response.ok(jsonEncode(user))
///         : Response.notFound('User not found');
///   }
/// }
/// ```
class Get {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates a Get annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Get([this.path = '/']);
}

/// Marks a method as a handler for HTTP POST requests.
///
/// Use this annotation on controller methods to map them to HTTP POST endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
/// POST requests are typically used for creating new resources.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Post('/') // Maps to POST /api/users/
///   Future<Response> createUser(Request request, @Body() UserDTO user) async {
///     final createdUser = await _service.create(user);
///     return Response(201, body: jsonEncode(createdUser));
///   }
/// }
/// ```
class Post {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates a Post annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Post([this.path = '/']);
}

/// Marks a method as a handler for HTTP PUT requests.
///
/// Use this annotation on controller methods to map them to HTTP PUT endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
/// PUT requests are typically used for updating existing resources with a complete replacement.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Put('/:id') // Maps to PUT /api/users/:id
///   Future<Response> updateUser(
///     Request request,
///     @Param('id') String id,
///     @Body() UserDTO user
///   ) async {
///     final updated = await _service.update(id, user);
///     return updated
///         ? Response.ok(jsonEncode({'success': true}))
///         : Response.notFound('User not found');
///   }
/// }
/// ```
class Put {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates a Put annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Put([this.path = '/']);
}

/// Marks a method as a handler for HTTP DELETE requests.
///
/// Use this annotation on controller methods to map them to HTTP DELETE endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
/// DELETE requests are typically used for removing resources.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Delete('/:id') // Maps to DELETE /api/users/:id
///   Future<Response> deleteUser(Request request, @Param('id') String id) async {
///     final deleted = await _service.delete(id);
///     return deleted
///         ? Response.ok(jsonEncode({'success': true}))
///         : Response.notFound('User not found');
///   }
/// }
/// ```
class Delete {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates a Delete annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Delete([this.path = '/']);
}

/// Marks a method as a handler for HTTP PATCH requests.
///
/// Use this annotation on controller methods to map them to HTTP PATCH endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
/// PATCH requests are typically used for partial updates to existing resources.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Patch('/:id') // Maps to PATCH /api/users/:id
///   Future<Response> partialUpdateUser(
///     Request request,
///     @Param('id') String id,
///     @Body() Map<String, dynamic> updates
///   ) async {
///     final updated = await _service.partialUpdate(id, updates);
///     return updated
///         ? Response.ok(jsonEncode({'success': true}))
///         : Response.notFound('User not found');
///   }
/// }
/// ```
class Patch {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates a Patch annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Patch([this.path = '/']);
}

/// Marks a method as a handler for HTTP HEAD requests.
///
/// Use this annotation on controller methods to map them to HTTP HEAD endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
/// HEAD requests are similar to GET requests but only return headers without a body.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   final UserService _service;
///
///   UserController(this._service);
///
///   @Head('/:id') // Maps to HEAD /api/users/:id
///   Future<Response> checkUserExists(Request request, @Param('id') String id) async {
///     final exists = await _service.exists(id);
///     return exists
///         ? Response(200, headers: {'X-Resource-Exists': 'true'})
///         : Response(404, headers: {'X-Resource-Exists': 'false'});
///   }
/// }
/// ```
class Head {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates a Head annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Head([this.path = '/']);
}

/// Marks a method as a handler for HTTP OPTIONS requests.
///
/// Use this annotation on controller methods to map them to HTTP OPTIONS endpoints.
/// The [path] parameter specifies the route path relative to the controller's base path.
/// OPTIONS requests are typically used to describe the communication options for the target resource.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Options('/') // Maps to OPTIONS /api/users/
///   Future<Response> getUserOptions(Request request) async {
///     return Response(200, headers: {
///       'Allow': 'GET, POST, OPTIONS',
///       'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
///     });
///   }
/// }
/// ```
class Options {
  /// The route path relative to the controller's base path.
  ///
  /// This can include path parameters (e.g., '/:id') which can be extracted
  /// using the @Param annotation in the method parameters.
  final String path;

  /// Creates an Options annotation with the specified path.
  ///
  /// [path] - The route path relative to the controller's base path.
  const Options([this.path = '/']);
}

/// Mounts a Router instance at the specified path.
///
/// Use this annotation on controller methods that return a Router instance
/// to mount that router at the specified path relative to the controller's base path.
/// This is useful for creating nested routers or modular routing structures.
///
/// Example:
/// ```dart
/// @Controller('/api')
/// class ApiController {
///   final UserController _userController;
///
///   ApiController(this._userController);
///
///   @Mount('/users') // Mounts the user router at /api/users
///   Router get userRouter => _userController.router;
///
///   @Get('/status')
///   Response getApiStatus(Request request) {
///     return Response.ok(jsonEncode({'status': 'online'}));
///   }
/// }
/// ```
class Mount {
  /// The path at which to mount the router.
  ///
  /// This path is relative to the controller's base path.
  final String path;

  /// Creates a Mount annotation with the specified path.
  ///
  /// [path] - The path at which to mount the router.
  const Mount([this.path = '/']);
}
