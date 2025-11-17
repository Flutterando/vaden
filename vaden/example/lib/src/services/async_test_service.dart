import 'package:example/src/repositories/async_test_repository.dart';
import 'package:vaden/vaden.dart';

/// Service that depends on AsyncTestRepository
@Service()
class AsyncTestService {
  final AsyncTestRepository repository;

  AsyncTestService(this.repository);

  Future<List<String>> getAllItems() async {
    return repository.findAll();
  }

  Future<String?> getItemById(String id) async {
    return repository.findById(id);
  }
}
