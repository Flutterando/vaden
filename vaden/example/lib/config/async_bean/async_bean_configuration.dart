import 'package:example/config/async_bean/database_connection.dart';
import 'package:vaden/vaden.dart';

/// Configuration that provides an async bean (Future<DatabaseConnection>)
/// This bean should be resolved BEFORE any repository that depends on it
@Configuration()
class AsyncBeanConfiguration {
  @Bean()
  Future<DatabaseConnection> databaseConnection(ApplicationSettings settings) async {
    final connectionString = settings['database']?['url'] ?? 'default://localhost:5432/test';
    return DatabaseConnection.connect(connectionString);
  }
}
