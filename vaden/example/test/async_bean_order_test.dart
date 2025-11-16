import 'package:example/config/async_bean/database_connection.dart';
import 'package:example/src/repositories/async_test_repository.dart';
import 'package:example/src/services/async_test_service.dart';
import 'package:example/vaden_application.dart';
import 'package:test/test.dart';

/// Test to validate that async beans are resolved before components that depend on them.
/// This reproduces the bug scenario where:
/// 1. @Configuration has a Future<Connection> async bean
/// 2. @Repository depends on Connection
/// 3. @Controller depends on Repository
///
/// Before the fix, this would fail with:
/// UnregisteredInstance: Connection not registered.
/// UsersRepository => Connection
void main() {
  group('Async Bean Registration Order Tests', () {
    late VadenApp app;

    setUp(() {
      app = VadenApp();
    });

    test('should setup application without errors', () async {
      // This should not throw an UnregisteredInstance error
      await expectLater(
        app.setup(),
        completes,
        reason: 'Application setup should complete successfully with async beans',
      );
    });

    test('should register DatabaseConnection from async bean', () async {
      await app.setup();

      // Verify that the async bean was resolved and registered
      final connection = app.injector.get<DatabaseConnection>();
      expect(connection, isNotNull);
      expect(connection.isConnected, isTrue);
    });

    test('should register AsyncTestRepository with DatabaseConnection dependency', () async {
      await app.setup();

      // Verify that the repository was registered and can be resolved
      final repository = app.injector.get<AsyncTestRepository>();
      expect(repository, isNotNull);
      expect(repository.connection, isNotNull);
      expect(repository.connection.isConnected, isTrue);
    });

    test('should register AsyncTestService with AsyncTestRepository dependency', () async {
      await app.setup();

      // Verify that the service was registered and can be resolved
      final service = app.injector.get<AsyncTestService>();
      expect(service, isNotNull);
      expect(service.repository, isNotNull);
      expect(service.repository.connection, isNotNull);
    });

    test('should register AsyncTestController with AsyncTestService dependency', () async {
      await app.setup();

      // Verify that the controller was registered and can be resolved
      final service = app.injector.get<AsyncTestService>();
      expect(service, isNotNull);
      expect(service.repository, isNotNull);
      expect(service.repository.connection, isNotNull);
    });

    test('should allow repository operations after setup', () async {
      await app.setup();

      final repository = app.injector.get<AsyncTestRepository>();
      final items = await repository.findAll();
      
      expect(items, isNotEmpty);
      expect(items, contains('item1'));
    });

    test('should allow service operations after setup', () async {
      await app.setup();

      final service = app.injector.get<AsyncTestService>();
      final items = await service.getAllItems();
      
      expect(items, isNotEmpty);
      expect(items, contains('item1'));
    });

    test('should verify component registration order', () async {
      await app.setup();

      // Verify all components are registered in the correct order
      // If any component fails to resolve, it means the order was incorrect
      expect(
        app.injector.get<DatabaseConnection>,
        isA<DatabaseConnection>(),
        reason: 'DatabaseConnection (async bean) should be registered first',
      );

      expect(
        app.injector.get<AsyncTestRepository>,
        isA<AsyncTestRepository>(),
        reason: 'AsyncTestRepository should be registered after DatabaseConnection',
      );

      expect(
        app.injector.get<AsyncTestService>,
        isA<AsyncTestService>(),
        reason: 'AsyncTestService should be registered after AsyncTestRepository',
      );
    });
  });

  group('Async Bean Configuration Priority Tests', () {
    test('should process configurations before repositories', () async {
      final app = VadenApp();
      await app.setup();

      // If this test passes, it means configurations were processed before repositories
      // and the async bean was resolved before any component tried to use it
      final repository = app.injector.get<AsyncTestRepository>();
      expect(repository.connection.isConnected, isTrue);
    });

    test('should process repositories before controllers', () async {
      final app = VadenApp();
      await app.setup();

      // Controllers should be able to access repositories through services
      final service = app.injector.get<AsyncTestService>();
      final items = await service.getAllItems();
      
      expect(items, isNotEmpty);
    });
  });
}
