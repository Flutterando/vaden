/// # Vaden Framework
///
/// A modern, annotation-driven backend framework for Dart applications.
///
/// Vaden is designed to simplify backend development by providing a structured,
/// declarative approach to building REST APIs with built-in dependency injection,
/// middleware support, and OpenAPI documentation capabilities.
///
/// ## Core Features
///
/// - **Annotation-driven development**: Define controllers, routes, and components using annotations
/// - **Dependency injection**: Built-in DI system powered by auto_injector
/// - **Middleware support**: Easy-to-use middleware system for request/response processing
/// - **OpenAPI integration**: Automatic API documentation generation
/// - **Type-safe serialization**: Robust data transfer object (DTO) handling
/// - **Security**: Guards for route protection and authentication
/// - **Validation**: Input validation through lucid_validation integration
///
/// ## Framework Architecture
///
/// Vaden is built on top of the Shelf ecosystem, providing a robust foundation
/// for handling HTTP requests and responses. The framework follows a modular
/// architecture with clear separation of concerns:
///
/// - **Controllers**: Handle incoming HTTP requests and define API endpoints
/// - **Services**: Contain business logic and application workflows
/// - **Repositories**: Manage data access and persistence
/// - **DTOs**: Define data transfer objects for request/response serialization
/// - **Guards**: Protect routes with authentication and authorization logic
/// - **Middlewares**: Process requests/responses for cross-cutting concerns
///
/// ## Getting Started
///
/// To use Vaden, import this library and start defining your application components
/// using the provided annotations. See the documentation for each component for
/// detailed usage instructions.
///
library;

// External package dependencies
export 'package:auto_injector/auto_injector.dart' hide Param;
export 'package:lucid_validation/lucid_validation.dart';
export 'package:shelf/shelf.dart';
export 'package:shelf/shelf_io.dart';
export 'package:shelf_multipart/shelf_multipart.dart';
export 'package:shelf_router/shelf_router.dart';

// Core annotations for defining application components
export 'src/annotations/annotation.dart';

// Extensions for enhancing framework functionality
export 'src/extensions/extensions.dart';

// Middleware implementations for common use cases
export 'src/middlewares/cors.dart';
export 'src/middlewares/enforce_json_content_type.dart';

// Core types and interfaces
export 'src/types/disposable.dart';
export 'src/types/dson.dart';
export 'src/types/mcp.dart';
export 'src/types/types.dart';

// Utility classes and services
export 'src/utils/app_configuration.dart';
export 'src/utils/openapi_config.dart';
export 'src/utils/resource_service.dart';
export 'src/utils/storage/storage.dart';
