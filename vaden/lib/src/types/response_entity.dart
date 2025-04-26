import 'dart:convert';

import 'package:vaden/vaden.dart';

/// Represents a Future that resolves to a ResponseEntity<T>.
///
/// This type alias is useful for asynchronous controller methods that need to
/// return a ResponseEntity after performing asynchronous operations.
typedef AsyncResponseEntity<T> = Future<ResponseEntity<T>>;

/// A class that represents an HTTP response with body, status code, and headers.
///
/// The ResponseEntity class provides a structured way to create HTTP responses
/// in controllers. It encapsulates the response body, status code, and headers,
/// allowing for a consistent approach to response generation across the application.
///
/// ResponseEntity is typically used as the return type for controller methods,
/// providing a clean interface for generating HTTP responses with various types of content.
///
/// Example:
/// ```dart
/// @Controller('/users')
/// class UserController {
///   @Get('/:id')
///   ResponseEntity<UserDTO> getUser(String id) {
///     final user = userService.findById(id);
///     return ResponseEntity(user);
///   }
///
///   @Post('/')
///   ResponseEntity<UserDTO> createUser(@Body() UserDTO user) {
///     final createdUser = userService.create(user);
///     return ResponseEntity(createdUser, statusCode: 201);
///   }
/// }
/// ```
class ResponseEntity<T> {
  /// The body content of the response.
  ///
  /// This can be of various types, including:
  /// - String: For plain text responses
  /// - List<int>: For binary data
  /// - Map<String, dynamic>: For JSON objects
  /// - Custom DTO classes: Will be serialized to JSON using the DSON system
  /// - Lists of the above types
  final T body;
  
  /// The HTTP status code for the response.
  ///
  /// Common status codes include:
  /// - 200: OK (default)
  /// - 201: Created
  /// - 204: No Content
  /// - 302: Found (redirect)
  /// - 304: Not Modified
  final int statusCode;
  
  /// Additional HTTP headers to include in the response.
  ///
  /// These headers will be merged with the default headers set by the framework.
  /// If a Content-Type header is not provided, it will be automatically set based
  /// on the type of the body content.
  final Map<String, String> headers;
  
  /// Creates a new ResponseEntity with the specified body, status code, and headers.
  ///
  /// Parameters:
  /// - [body]: The body content of the response.
  /// - [statusCode]: The HTTP status code for the response (default: 200).
  /// - [headers]: Additional HTTP headers to include in the response (default: empty map).
  ResponseEntity(
    this.body, {
    this.statusCode = 200,
    this.headers = const {},
  });

  /// Generates a shelf Response object from this ResponseEntity.
  ///
  /// This method converts the ResponseEntity into a shelf Response object that can be
  /// returned from a controller method or middleware. The conversion process depends
  /// on the type of the body content:
  /// - String: Returned as plain text
  /// - List<int>: Returned as binary data
  /// - Map<String, dynamic> and similar map types: Encoded as JSON
  /// - Custom DTO classes: Serialized to JSON using the provided DSON instance
  /// - Lists of the above types: Processed accordingly
  ///
  /// Parameters:
  /// - [dson]: The DSON instance to use for serializing custom DTO classes.
  ///
  /// Returns:
  /// - A shelf Response object with the appropriate status code, body, and headers.
  Response generateResponse(DSON dson) {
    if (body is String) {
      return Response(statusCode,
          body: body, headers: _enforceContentType(headers, 'text/plain'));
    } else if (body is List<int>) {
      return Response(statusCode,
          body: body,
          headers: _enforceContentType(headers, 'application/octet-stream'));
    } else if (body is Map<String, dynamic>) {
      return Response(statusCode,
          body: jsonEncode(body),
          headers: _enforceContentType(headers, 'application/json'));
    } else if (body is Map<String, Object>) {
      return Response(statusCode,
          body: jsonEncode(body),
          headers: _enforceContentType(headers, 'application/json'));
    } else if (body is Map<String, String>) {
      return Response(statusCode,
          body: jsonEncode(body),
          headers: _enforceContentType(headers, 'application/json'));
    } else if (body is List<Map<String, dynamic>>) {
      return Response(statusCode,
          body: jsonEncode(body),
          headers: _enforceContentType(headers, 'application/json'));
    } else if (body is List<Map<String, String>>) {
      return Response(statusCode,
          body: jsonEncode(body),
          headers: _enforceContentType(headers, 'application/json'));
    } else if (body is List<Map<String, Object>>) {
      return Response(statusCode,
          body: jsonEncode(body),
          headers: _enforceContentType(headers, 'application/json'));
    } else {
      if (body is List) {
        final json = (body as List).map((e) => dson.toJson(e)).toList();
        return Response(statusCode,
            body: jsonEncode(json),
            headers: _enforceContentType(headers, 'application/json'));
      }
      return Response(statusCode,
          body: jsonEncode(dson.toJson(body)),
          headers: _enforceContentType(headers, 'application/json'));
    }
  }

  /// Ensures that the response headers include a Content-Type header.
  ///
  /// This private method adds a Content-Type header to the response headers if one
  /// is not already present. This ensures that the client knows how to interpret
  /// the response body correctly. The method checks for both 'Content-Type' and
  /// 'content-type' keys to handle case sensitivity differences.
  ///
  /// Parameters:
  /// - [headers]: The original headers map to be enriched.
  /// - [contentType]: The content type value to set if none is present, such as
  ///   'application/json', 'text/plain', or 'application/octet-stream'.
  ///
  /// Returns:
  /// - A new headers map with the Content-Type header added if necessary,
  ///   preserving all other original header values.
  Map<String, String> _enforceContentType(
      Map<String, String> headers, String contentType) {
    final Map<String, String> enforcedHeaders =
    Map<String, String>.from(headers);

    if (enforcedHeaders['content-type'] == null &&
        enforcedHeaders['Content-Type'] == null) {
      enforcedHeaders['Content-Type'] = contentType;
    }

    return enforcedHeaders;
  }
}
