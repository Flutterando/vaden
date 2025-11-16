import 'package:example/config/async_bean/database_connection.dart';
import 'package:vaden/vaden.dart';

/// Repository that depends on DatabaseConnection from async bean
/// This should NOT fail with "Connection not registered" error
@Repository()
class AsyncTestRepository {
  final DatabaseConnection connection;

  AsyncTestRepository(this.connection);

  Future<List<String>> findAll() async {
    if (!connection.isConnected) {
      throw Exception('Database not connected');
    }
    return ['item1', 'item2', 'item3'];
  }

  Future<String?> findById(String id) async {
    if (!connection.isConnected) {
      throw Exception('Database not connected');
    }
    return 'item_$id';
  }
}
