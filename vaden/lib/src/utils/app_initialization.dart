/// A class for managing and tracking the application's initialization process.
///
/// The InitializationSettings class provides a mechanism to execute a list of asynchronous
/// or synchronous initialization functions during the startup of the application. It waits
/// for all provided functions to complete before proceeding and tracks whether the initialization
/// was successful.
///
/// This is useful for setting up services, loading essential resources, or performing
/// any startup tasks that must be completed before the application becomes fully operational.
///
/// Example usage:
/// ```dart
/// Future<void> initializeDatabase() async {
///   // Database initialization logic
/// }
///
/// void initializeLogger() {
///   // Logger setup logic
/// }
///
/// void main() async {
///   final initialization = await InitializationSettings.load([
///     initializeDatabase,
///     initializeLogger,
///   ]);
///
///   if (initialization()) {
///     print('Application initialized successfully.');
///   } else {
///     print('Application failed to initialize.');
///   }
/// }
/// ```
///
/// This approach ensures that all necessary startup tasks are completed in a
/// safe and consistent manner, improving application stability.
class InitializationSettings {
  /// Internal flag indicating whether all initialization functions completed successfully.
  final bool _completed;

  /// Private constructor that initializes the [_completed] status.
  ///
  /// This constructor is private to enforce the use of the [load] factory method
  /// for creating instances of InitializationSettings.
  InitializationSettings._(this._completed);

  /// Executes a list of initialization functions and waits for their completion.
  ///
  /// This factory method runs each function provided in the [functions] list. It automatically
  /// handles both synchronous and asynchronous functions, ensuring that all functions are completed.
  /// If any function throws an exception, the initialization is considered failed.
  ///
  /// Parameters:
  /// - [functions]: A list of functions to execute. Each function can return either
  ///   a Future or void.
  ///
  /// Returns:
  /// - An InitializationSettings instance indicating whether initialization was successful.
  ///
  /// Example:
  /// ```dart
  /// final settings = await InitializationSettings.load([setupCache, initializeServices]);
  /// if (settings()) { ... }
  /// ```
  static Future<InitializationSettings> load(List<Function> functions) async {
    try {
      await Future.wait(functions.map((function) {
        var result = function();
        if (result is Future) {
          return result;
        } else {
          return Future.value();
        }
      }));
      return InitializationSettings._(true);
    } catch (e, stackTrace) {
      print('Error starting functions: $e');
      print('StackTrace: $stackTrace');
      return InitializationSettings._(false);
    }
  }

  /// Returns the completion status of the initialization process.
  ///
  /// This operator allows checking whether all initialization functions completed successfully.
  ///
  /// Returns:
  /// - `true` if initialization was successful, `false` otherwise.
  bool operator() => _completed;
}
