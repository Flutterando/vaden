/// Interface for classes that need to release resources when they are no longer needed.
///
/// The Disposable interface is used to define a standard way for components in the
/// Vaden framework to clean up resources when they are no longer needed. This is
/// particularly important for components that hold onto external resources such as
/// database connections, file handles, or network sockets.
///
/// When the Vaden application is shut down, the framework will automatically call
/// the [dispose] method on all registered components that implement this interface.
/// This ensures that resources are properly released and prevents resource leaks.
///
/// Example:
/// ```dart
/// @Service()
/// class DatabaseService implements Disposable {
///   late final Database _database;
///
///   Future<void> initialize() async {
///     _database = await Database.connect('connection_string');
///   }
///
///   Future<List<Map<String, dynamic>>> query(String sql) async {
///     return _database.query(sql);
///   }
///
///   @override
///   void dispose() {
///     // Close the database connection when the service is disposed
///     _database.close();
///     print('DatabaseService disposed');
///   }
/// }
/// ```
///
/// Components that implement Disposable should ensure that their [dispose] method
/// is idempotent (can be called multiple times without causing errors) and should
/// handle any exceptions that might occur during resource cleanup.
abstract interface class Disposable {
  /// Releases resources held by this object.
  ///
  /// This method is called by the Vaden framework when the application is shut down
  /// or when the component is explicitly disposed. It should release all resources
  /// held by the object, such as closing database connections, file handles, or
  /// network sockets.
  ///
  /// Implementations should ensure that this method is idempotent (can be called
  /// multiple times without causing errors) and should handle any exceptions that
  /// might occur during resource cleanup.
  void dispose();
}
