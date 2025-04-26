import 'dart:io';

import 'package:vaden/vaden.dart';

/// Represents the core application structure in Vaden,
/// managing server startup, dependency injection, and routing.
///
/// [VadenApplication] defines the main lifecycle methods and
/// infrastructure components required to run a Vaden server.
///
/// It provides access to:
/// - The [Injector] for dependency management
/// - The [Router] for HTTP route handling
///
/// Applications must extend this class to configure and launch
/// their services.
///
/// The [instance] field holds a static reference to the running
/// application and must be initialized using [registerInstance].
abstract class VadenApplication {
  /// Starts the HTTP server and runs the application with the
  /// provided command-line [args].
  ///
  /// Returns the [HttpServer] instance once started.
  Future<HttpServer> run(List<String> args);

  /// Sets up internal application components, dependency injection,
  /// and middleware before the server starts.
  Future<void> setup();

  /// Provides access to the dependency [Injector] containing
  /// all registered beans and services.
  Injector get injector;

  /// Provides access to the [Router] instance used for
  /// defining HTTP routes.
  Router get router;

  /// Holds the global static instance of the running application.
  static late final VadenApplication instance;

  /// Registers the global application [instance].
  ///
  /// This must be called during the application initialization
  /// to allow access to the application context.
  static void registerInstance(VadenApplication app) {
    instance = app;
  }
}
