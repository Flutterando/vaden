part of 'annotation.dart';

/// Provides OpenAPI documentation for a controller.
///
/// Use this annotation on controller classes to specify the tag and description
/// that will be used in the generated OpenAPI documentation. Tags are used to
/// group related endpoints in the API documentation.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// @Api(tag: 'Users', description: 'User management endpoints')
/// class UserController {
///   // Controller methods...
/// }
/// ```
class Api {
  /// The tag name for grouping related endpoints in the OpenAPI documentation.
  final String tag;

  /// A description of the API endpoints in this controller.
  final String description;

  /// Creates an Api annotation with the specified tag and description.
  ///
  /// [tag] - The tag name for grouping related endpoints.
  /// [description] - A description of the API endpoints (optional).
  const Api({required this.tag, this.description = ''});
}

/// Provides OpenAPI documentation for an endpoint operation.
///
/// Use this annotation on controller methods to specify the summary and description
/// that will be used in the generated OpenAPI documentation for the endpoint.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// @Api(tag: 'Users')
/// class UserController {
///   @Get('/:id')
///   @ApiOperation(
///     summary: 'Get user by ID',
///     description: 'Retrieves a user by their unique identifier.'
///   )
///   Future<Response> getUserById(Request request, @Param('id') String id) {
///     // Method implementation...
///   }
/// }
/// ```
class ApiOperation {
  /// A short summary of what the operation does.
  final String summary;

  /// A verbose explanation of the operation behavior.
  final String description;

  /// Creates an ApiOperation annotation with the specified summary and description.
  ///
  /// [summary] - A short summary of what the operation does.
  /// [description] - A verbose explanation of the operation behavior (optional).
  const ApiOperation({required this.summary, this.description = ''});
}

/// Describes a possible response from an API endpoint.
///
/// Use this annotation on controller methods to document the possible responses
/// that can be returned by the endpoint, including status codes, descriptions,
/// and content types.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/:id')
///   @ApiOperation(summary: 'Get user by ID')
///   @ApiResponse(200,
///     description: 'User found',
///     content: ApiContent(type: 'application/json', schema: UserDTO)
///   )
///   @ApiResponse(404, description: 'User not found')
///   Future<Response> getUserById(Request request, @Param('id') String id) {
///     // Method implementation...
///   }
/// }
/// ```
class ApiResponse {
  /// The HTTP status code for this response.
  final int statusCode;

  /// A description of the response.
  final String description;

  /// The content type and schema of the response body.
  final ApiContent? content;

  /// Creates an ApiResponse annotation with the specified status code, description, and content.
  ///
  /// [statusCode] - The HTTP status code for this response.
  /// [description] - A description of the response (optional).
  /// [content] - The content type and schema of the response body (optional).
  const ApiResponse(this.statusCode, {this.description = '', this.content});
}

/// Describes the content type and schema of a request or response body.
///
/// Use this annotation with ApiResponse to document the content type and schema
/// of the response body.
///
/// Example:
/// ```dart
/// @ApiResponse(200,
///   description: 'Success',
///   content: ApiContent(type: 'application/json', schema: UserDTO)
/// )
/// ```
class ApiContent {
  /// The media type of the content (e.g., 'application/json').
  final String type;

  /// The schema type of the content (typically a DTO class).
  final Type? schema;

  /// Creates an ApiContent annotation with the specified type and schema.
  ///
  /// [type] - The media type of the content (e.g., 'application/json').
  /// [schema] - The schema type of the content (typically a DTO class).
  const ApiContent({
    required this.type,
    this.schema,
  });
}

/// Provides OpenAPI documentation for a path parameter.
///
/// Use this annotation along with @Param to document path parameters in the
/// generated OpenAPI documentation.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/:id')
///   @ApiOperation(summary: 'Get user by ID')
///   Future<Response> getUserById(
///     Request request,
///     @Param('id') @ApiParam(description: 'User ID', required: true) String id
///   ) {
///     // Method implementation...
///   }
/// }
/// ```
class ApiParam {
  /// The name of the parameter.
  ///
  /// If null, the parameter name from @Param will be used.
  final String? name;

  /// A description of the parameter.
  final String description;

  /// Indicates whether the parameter is required.
  final bool required;

  /// Creates an ApiParam annotation with the specified name, description, and required flag.
  ///
  /// [name] - The name of the parameter (optional).
  /// [description] - A description of the parameter (optional).
  /// [required] - Indicates whether the parameter is required (default: false).
  const ApiParam({this.name, this.description = '', this.required = false});
}

/// Provides OpenAPI documentation for a query parameter.
///
/// Use this annotation along with @Query to document query parameters in the
/// generated OpenAPI documentation.
///
/// Example:
/// ```dart
/// @Controller('/api/users')
/// class UserController {
///   @Get('/')
///   @ApiOperation(summary: 'Search users')
///   Future<Response> searchUsers(
///     Request request,
///     @Query('name') @ApiQuery(description: 'Filter by name', required: false) String? name,
///     @Query('age') @ApiQuery(description: 'Filter by age', required: false) int? age
///   ) {
///     // Method implementation...
///   }
/// }
/// ```
class ApiQuery {
  /// The name of the query parameter.
  ///
  /// If null, the parameter name from @Query will be used.
  final String? name;

  /// A description of the query parameter.
  final String description;

  /// Indicates whether the query parameter is required.
  final bool required;

  /// Creates an ApiQuery annotation with the specified name, description, and required flag.
  ///
  /// [name] - The name of the query parameter (optional).
  /// [description] - A description of the query parameter (optional).
  /// [required] - Indicates whether the query parameter is required (default: false).
  const ApiQuery({this.name, this.description = '', this.required = false});
}

/// Specifies the security schemes required for an API endpoint.
///
/// Use this annotation on controller classes or methods to document the security
/// requirements for accessing the API endpoints in the generated OpenAPI documentation.
///
/// Example:
/// ```dart
/// @Controller('/api/admin')
/// @Api(tag: 'Admin')
/// @ApiSecurity(['bearerAuth'])
/// class AdminController {
///   // All endpoints in this controller require bearer authentication
///
///   @Get('/stats')
///   @ApiOperation(summary: 'Get admin statistics')
///   Future<Response> getStats(Request request) {
///     // Method implementation...
///   }
///
///   @Post('/settings')
///   @ApiSecurity(['bearerAuth', 'apiKey'])
///   // This endpoint requires both bearer authentication and an API key
///   Future<Response> updateSettings(Request request) {
///     // Method implementation...
///   }
/// }
/// ```
class ApiSecurity {
  /// The list of security scheme names required for the endpoint.
  ///
  /// These names should correspond to security schemes defined in the
  /// OpenAPI configuration.
  final List<String> schemes;

  /// Creates an ApiSecurity annotation with the specified security schemes.
  ///
  /// [schemes] - The list of security scheme names required for the endpoint.
  const ApiSecurity(this.schemes);
}
