import 'package:vaden/vaden.dart' hide Server, Response;
import 'package:vaden/vaden_openapi.dart';

/// Configuration class for generating OpenAPI documentation in the Vaden framework.
///
/// The OpenApiConfig class collects and organizes information about the API endpoints,
/// data models, and other metadata needed to generate comprehensive OpenAPI documentation.
/// It works in conjunction with the OpenAPI annotations (such as @Api, @ApiOperation, etc.)
/// to provide a complete description of the API.
///
/// This class is typically used by the Vaden framework internally to generate OpenAPI
/// documentation automatically based on the annotations in your controllers and DTOs.
/// The generated documentation can be served as a JSON or YAML file and viewed using
/// tools like Swagger UI or Redoc.
///
/// Example usage:
/// ```dart
/// void main() async {
///   final app = await VadenApp.create();
///
///   // Generate and serve OpenAPI documentation
///   app.useOpenApi();
///
///   await app.listen();
/// }
/// ```
///
/// With the above setup, the OpenAPI documentation will be available at the '/api-docs'
/// endpoint, and a Swagger UI interface will be available at '/swagger'.
class OpenApiConfig {
  /// The paths section of the OpenAPI document.
  ///
  /// This map contains information about all the API endpoints, including their
  /// HTTP methods, parameters, request bodies, responses, and other metadata.
  final Map<String, dynamic> _paths;

  /// The components section of the OpenAPI document.
  ///
  /// This map contains schema definitions for all the data models (DTOs) used in the API.
  /// These schemas are referenced by the paths section to describe request and response bodies.
  final Map<Type, ToOpenApiNormalMap> _components;

  /// The application settings containing configuration values for the API.
  ///
  /// These settings are used to generate server information and other metadata
  /// for the OpenAPI document.
  final ApplicationSettings _settings;

  /// The list of API annotations found in the controllers.
  ///
  /// These annotations provide metadata about the API endpoints, such as tags
  /// and descriptions, which are used to organize the OpenAPI documentation.
  final List<Api> _apis;

  /// Creates a new OpenApiConfig instance with the specified paths, components, APIs, and settings.
  ///
  /// Parameters:
  /// - [_paths]: The paths section of the OpenAPI document.
  /// - [_components]: The components section of the OpenAPI document.
  /// - [_apis]: The list of API annotations found in the controllers.
  /// - [_settings]: The application settings containing configuration values for the API.
  OpenApiConfig(
    this._paths,
    this._components,
    this._apis,
    this._settings,
  );

  /// Creates a factory function for generating OpenApiConfig instances.
  ///
  /// This static method returns a function that can create OpenApiConfig instances
  /// with the specified paths and APIs. The returned function takes a DSON instance
  /// and application settings as parameters, which are used to populate the components
  /// section of the OpenAPI document.
  ///
  /// This factory pattern allows for deferred creation of the OpenApiConfig until
  /// all the necessary dependencies (DSON and ApplicationSettings) are available.
  ///
  /// Parameters:
  /// - [paths]: The paths section of the OpenAPI document.
  /// - [apis]: The list of API annotations found in the controllers.
  ///
  /// Returns:
  /// - A function that creates an OpenApiConfig instance with the specified paths and APIs.
  static OpenApiConfig Function(DSON dson, ApplicationSettings settings) create(
    Map<String, dynamic> paths,
    List<Api> apis,
  ) {
    return (dson, settings) {
      return OpenApiConfig(
        paths,
        dson.apiEntries,
        apis,
        settings,
      );
    };
  }

  /// Gets the local server information for the OpenAPI document.
  ///
  /// This getter creates a Server object with the URL and description of the local server
  /// based on the host and port specified in the application settings. This information
  /// is used in the servers section of the OpenAPI document to indicate where the API
  /// is available.
  ///
  /// Returns:
  /// - A Server object representing the local server where the API is hosted.
  Server get localServer {
    return Server(
      url:
          'http://${_settings['server']['host']}:${_settings['server']['port']}',
      description: 'Local server',
    );
  }

  /// Gets the tags for the OpenAPI document.
  ///
  /// This getter creates a list of Tag objects based on the API annotations found in the
  /// controllers. Tags are used to group operations in the OpenAPI document, making it
  /// easier to navigate and understand the API structure.
  ///
  /// Each Tag includes a name and description derived from the corresponding Api annotation.
  ///
  /// Returns:
  /// - A list of Tag objects representing the different sections of the API.
  List<Tag> get tags {
    return _apis.map(
      (api) {
        return Tag(
          name: api.tag,
          description: api.description,
        );
      },
    ).toList();
  }

  /// Gets the paths section of the OpenAPI document.
  ///
  /// This getter converts the raw paths data into a map of PathItem objects, which
  /// represent the individual endpoints of the API. Each PathItem contains information
  /// about the operations (GET, POST, etc.) available at that path, along with their
  /// parameters, request bodies, responses, and other metadata.
  ///
  /// Returns:
  /// - A map of path strings to PathItem objects representing the API endpoints.
  Map<String, PathItem> get paths {
    return _paths.map(
      (key, value) {
        return MapEntry(key, PathItem.fromJson(value));
      },
    );
  }

  /// Gets the schemas section of the OpenAPI document.
  ///
  /// This getter converts the components data into a map of Schema objects, which
  /// represent the data models (DTOs) used in the API. These schemas define the structure
  /// of request and response bodies, and are referenced by the operations in the paths section.
  ///
  /// The key for each schema is the string representation of the corresponding Type,
  /// and the value is a Schema object created from the ToOpenApiNormalMap data.
  ///
  /// Returns:
  /// - A map of type names to Schema objects representing the data models used in the API.
  Map<String, Schema> get schemas {
    return _components.map(
      (key, value) {
        return MapEntry(key.toString(), Schema.fromJson(value));
      },
    );
  }
}
