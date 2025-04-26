---
sidebar_position: 5
---

# Initialization Warm Up

Vaden includes a built-in initialization warm-up process to ensure critical startup tasks are completed **before** the server begins handling requests.  

## AppWarmup

To configure initialization tasks, you should now create a class like `app_warmup.dart` and define components that implement either:

- `ApplicationRunner` – runs when the application starts, regardless of arguments.
- `CommandLineRunner` – runs based on specific command-line arguments passed at startup.

Example:

```dart
import 'package:vaden/vaden.dart';

@Component()
class AppWarmup implements ApplicationRunner {
  @override
  Future<void> run(VadenApplication app) async {
    print('ApplicationRunner');
  }
}

@Component()
class AppRunner implements CommandLineRunner {
  @override
  Future<void> run(List<String> args) async {
    print('My args: $args');
  }
}
```

### ApplicationRunner

- Runs automatically at application startup.
- Suitable for general initialization tasks like setting up services, running migrations, preparing caches, etc.

Example:

```dart
@Component()
class AppWarmup implements ApplicationRunner {
  @override
  Future<void> run(VadenApplication app) async {
    await prepareDatabase();
    initializeLogger();
  }
}
```

### CommandLineRunner

- Runs based on the command-line arguments passed to the app.
- Allows conditional startup behavior based on the arguments.

Example:

```dart
@Component()
class AppRunner implements CommandLineRunner {
  @override
  Future<void> run(List<String> args) async {
    if (args.contains('migrate')) {
      await runMigrations();
    } else if (args.contains('seed')) {
      await seedDatabase();
    }
  }
}
```

### Error Handling

- If any `run` method throws an exception, the error is printed and the server will **not start**.
- This ensures the application never runs in a partially initialized state.
