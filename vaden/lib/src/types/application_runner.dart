import 'package:vaden/src/types/vaden_application.dart';

/// Defines a contract for components that should execute
/// automatically during application startup.
///
/// Classes that implement [ApplicationRunner] are discovered and
/// executed before the server begins handling any requests.
///
/// Typical use cases include:
/// - Initializing resources
/// - Running database migrations
/// - Preloading caches
/// - Setting up external service connections
///
/// The [run] method receives the [VadenApplication] instance,
/// allowing access to configuration, context, and registered beans.
///
/// If an exception is thrown during execution, the application
/// startup process will fail, preventing the server from starting.
abstract class ApplicationRunner {
  /// Executes startup logic before the server becomes ready.
  ///
  /// The [app] parameter provides access to the running
  /// [VadenApplication] instance.
  ///
  /// Throws an exception to prevent the server from starting
  /// if initialization fails.
  Future<void> run(VadenApplication app);
}
