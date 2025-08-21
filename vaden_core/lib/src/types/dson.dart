/// Type definition for a function that converts a JSON map to an object of type T.
///
/// This function is used by the DSON system to deserialize JSON data into
/// strongly-typed objects.
typedef FromJsonFunction<T> = T Function(Map<String, dynamic> json);

/// Type definition for a function that converts an object of type T to a JSON map.
///
/// This function is used by the DSON system to serialize objects into JSON data
/// for transmission over the network.
typedef ToJsonFunction<T> = Map<String, dynamic> Function(T object);

/// Type definition for a map that represents the OpenAPI schema for a type.
///
/// This map is used to generate OpenAPI documentation for DTOs.
typedef ToOpenApiNormalMap = Map<String, dynamic>;

/// Data Serialization Object Notation (DSON) system for Vaden.
///
/// DSON is a core component of the Vaden framework that handles serialization and
/// deserialization of data transfer objects (DTOs). It provides a type-safe way to
/// convert between JSON data and strongly-typed Dart objects.
///
/// The DSON system maintains mappings between types and their serialization/deserialization
/// functions, allowing for automatic conversion of request and response bodies in controllers.
///
/// Implementations of DSON should provide the necessary mappings for all DTOs used in the
/// application by implementing the `getMaps()` method.
///
/// Example implementation:
/// ```dart
/// @Component()
/// class AppDSON extends DSON {
///   @override
///   (Map<Type, FromJsonFunction>, Map<Type, ToJsonFunction>, Map<Type, ToOpenApiNormalMap>) getMaps() {
///     return (
///       <Type, FromJsonFunction>{
///         UserDTO: (json) => UserDTO.fromJson(json),
///         ProductDTO: (json) => ProductDTO.fromJson(json),
///       },
///       <Type, ToJsonFunction>{
///         UserDTO: (user) => (user as UserDTO).toJson(),
///         ProductDTO: (product) => (product as ProductDTO).toJson(),
///       },
///       <Type, ToOpenApiNormalMap>{
///         UserDTO: {
///           'type': 'object',
///           'properties': {
///             'id': {'type': 'string'},
///             'name': {'type': 'string'},
///             'email': {'type': 'string'},
///           },
///           'required': ['id', 'name', 'email'],
///         },
///         // Other OpenAPI schemas...
///       },
///     );
///   }
/// }
/// ```
abstract class DSON {
  /// Map of types to their deserialization functions.
  late final Map<Type, FromJsonFunction> _mapFromJson;

  /// Map of types to their serialization functions.
  late final Map<Type, ToJsonFunction> _mapToJson;

  /// Map of types to their OpenAPI schema definitions.
  late final Map<Type, ToOpenApiNormalMap> _mapToOpenApi;

  /// Creates a new DSON instance and initializes the serialization maps.
  ///
  /// This constructor calls the `getMaps()` method to obtain the mappings
  /// between types and their serialization/deserialization functions.
  DSON() {
    final maps = getMaps();
    _mapFromJson = maps.$1;
    _mapToJson = maps.$2;
    _mapToOpenApi = maps.$3;
  }

  /// Returns the mappings between types and their serialization/deserialization functions.
  ///
  /// This method must be implemented by subclasses to provide the necessary mappings
  /// for all DTOs used in the application.
  ///
  /// Returns a tuple containing:
  /// - Map of types to their deserialization functions
  /// - Map of types to their serialization functions
  /// - Map of types to their OpenAPI schema definitions
  (
    Map<Type, FromJsonFunction>,
    Map<Type, ToJsonFunction>,
    Map<Type, ToOpenApiNormalMap>,
  ) getMaps();

  /// Converts a JSON map to an object of type T.
  ///
  /// This method uses the deserialization function registered for type T to convert
  /// the JSON map into a strongly-typed object. If no deserialization function is
  /// registered for type T, a ResponseException is thrown.
  ///
  /// Example:
  /// ```dart
  /// final userJson = {'id': '123', 'name': 'John Doe', 'email': 'john@example.com'};
  /// final user = dson.fromJson<UserDTO>(userJson);
  /// ```
  ///
  /// Parameters:
  /// - [json]: The JSON map to convert.
  ///
  /// Returns:
  /// - An object of type T created from the JSON map.
  ///
  /// Throws:
  /// - ResponseException: If no deserialization function is registered for type T.
  T fromJson<T>(Map<String, dynamic> json) {
    final FromJsonFunction? fromJsonFunction = _mapFromJson[T];
    if (fromJsonFunction == null) {
      throw Exception({'error': '$T is not a DTO'});
    }
    return fromJsonFunction(json);
  }

  /// Converts a list of JSON maps to a list of objects of type T.
  ///
  /// This method applies the [fromJson] method to each element in the list.
  ///
  /// Example:
  /// ```dart
  /// final usersJson = [
  ///   {'id': '123', 'name': 'John Doe', 'email': 'john@example.com'},
  ///   {'id': '456', 'name': 'Jane Smith', 'email': 'jane@example.com'},
  /// ];
  /// final users = dson.fromJsonList<UserDTO>(usersJson);
  /// ```
  ///
  /// Parameters:
  /// - [json]: The list of JSON maps to convert.
  ///
  /// Returns:
  /// - A list of objects of type T created from the JSON maps.
  List<T> fromJsonList<T>(List json) {
    return json.map((e) => fromJson<T>(e)!).toList();
  }

  /// Converts an object of type T to a JSON map.
  ///
  /// This method uses the serialization function registered for type T to convert
  /// the object into a JSON map. If no serialization function is registered for
  /// type T, a ResponseException is thrown.
  ///
  /// Example:
  /// ```dart
  /// final user = UserDTO(id: '123', name: 'John Doe', email: 'john@example.com');
  /// final userJson = dson.toJson<UserDTO>(user);
  /// ```
  ///
  /// Parameters:
  /// - [object]: The object to convert.
  ///
  /// Returns:
  /// - A JSON map created from the object.
  ///
  /// Throws:
  /// - ResponseException: If no serialization function is registered for type T.
  Map<String, dynamic> toJson<T>(T object) {
    final ToJsonFunction<T>? toJsonFunction = _mapToJson[T];
    if (toJsonFunction == null) {
      throw Exception({'error': '$T is not a DTO'});
    }
    return toJsonFunction(object);
  }

  Map<String, dynamic> toJsonByType(dynamic object, Type type) {
    final ToJsonFunction? toJsonFunction = _mapToJson[type];
    if (toJsonFunction == null) {
      throw Exception({'error': '$type is not a DTO'});
    }
    return toJsonFunction(object);
  }

  /// Converts a list of objects of type T to a list of JSON maps.
  ///
  /// This method applies the [toJson] method to each element in the list.
  ///
  /// Example:
  /// ```dart
  /// final users = [
  ///   UserDTO(id: '123', name: 'John Doe', email: 'john@example.com'),
  ///   UserDTO(id: '456', name: 'Jane Smith', email: 'jane@example.com'),
  /// ];
  /// final usersJson = dson.toJsonList<UserDTO>(users);
  /// ```
  ///
  /// Parameters:
  /// - [object]: The list of objects to convert.
  ///
  /// Returns:
  /// - A list of JSON maps created from the objects.
  List<Map<String, dynamic>> toJsonList<T>(List<T> object) {
    return object.map((e) => toJson<T>(e)).toList();
  }

  /// Returns the OpenAPI schema for type T.
  ///
  /// This method retrieves the OpenAPI schema registered for type T. If no schema
  /// is registered for type T, null is returned.
  ///
  /// Example:
  /// ```dart
  /// final userSchema = dson.toOpenApi<UserDTO>();
  /// ```
  ///
  /// Returns:
  /// - The OpenAPI schema for type T, or null if no schema is registered.
  Map<String, dynamic>? toOpenApi<T>() {
    final toOpenApiNormalMap = _mapToOpenApi[T];
    if (toOpenApiNormalMap == null) {
      return null;
    }
    return toOpenApiNormalMap;
  }

  /// Returns all registered OpenAPI schemas.
  ///
  /// This getter provides access to all OpenAPI schemas registered in the DSON system.
  /// It is used by the OpenAPI documentation generator to include all DTO schemas
  /// in the generated documentation.
  ///
  /// Returns:
  /// - A map of types to their OpenAPI schemas.
  Map<Type, ToOpenApiNormalMap> get apiEntries => _mapToOpenApi;

  void addToJson<T>(ToJsonFunction toJson) {
    _mapToJson[T] = toJson;
  }

  void addFromJson<T>(FromJsonFunction<T> fromJson) {
    _mapFromJson[T] = fromJson;
  }

  void addToOpenApi<T>(ToOpenApiNormalMap toOpenApi) {
    _mapToOpenApi[T] = toOpenApi;
  }
}
