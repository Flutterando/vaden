/// Simulates a database connection that needs async initialization
class DatabaseConnection {
  final String connectionString;
  final bool isConnected;

  DatabaseConnection(this.connectionString, this.isConnected);

  /// Simulates async connection to database
  static Future<DatabaseConnection> connect(String connectionString) async {
    // Simulate async connection
    await Future.delayed(Duration(milliseconds: 100));
    return DatabaseConnection(connectionString, true);
  }

  void close() {
    // Close connection
  }
}
