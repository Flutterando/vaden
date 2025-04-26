/// Defines a contract for components that should execute
/// based on command-line arguments during application startup.
///
/// Classes that implement [CommandLineRunner] are discovered and
/// executed with the arguments passed when starting the application.
///
/// Typical use cases include:
/// - Running database migrations manually
/// - Seeding test data
/// - Starting background jobs
///
/// The [run] method receives the list of [args] provided at startup.
///
/// If an exception is thrown during execution, the application
/// startup process will fail, preventing the server from starting.
abstract class CommandLineRunner {
  /// Executes logic based on the provided command-line arguments.
  ///
  /// The [args] parameter contains the list of arguments passed
  /// when the application was started.
  ///
  /// Throws an exception to prevent the server from starting
  /// if initialization fails.
  Future<void> run(List<String> args);
}
