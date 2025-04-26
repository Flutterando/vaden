---
sidebar_position: 5
---

# Initialization Warm Up

Vaden includes a built-in initialization warm-up process to ensure critical startup tasks are completed **before** the server begins handling requests.  
This system allows for operations such as database migrations, cache preloading, or external service connections to be executed during application boot.

By default, the initialization system runs no tasks unless you explicitly provide them.

## Boot Method

Inside your `@Configuration()` class, you can define the `boot` method, which returns an `InitializationSettings`.  
This method executes a list of startup functions before the server starts:

```dart
@Configuration()
class AppConfiguration {
  @Bean()
  ApplicationSettings settings() {
    return ApplicationSettings.load('application.yaml');
  }

  @Bean()
  Future<InitializationSettings> boot() async {
    return InitializationSettings.load([]);
  }

  @Bean()
  Pipeline globalMiddleware(ApplicationSettings settings) {
    return Pipeline()
        .addMiddleware(cors(allowedOrigins: ['*']))
        .addVadenMiddleware(EnforceJsonContentType())
        .addMiddleware(logRequests());
  }
}
```

At startup, the server will wait for all functions in the list to complete successfully.  
If any function fails (throws an error), the server **will not start**.

## Adding Initialization Functions

You can specify which tasks should run by adding them to the list passed to `InitializationSettings.load()`:

```dart
@Bean()
Future<InitializationSettings> boot(Initialization init) async {
  return InitializationSettings.load([
    init.start,
  ]);
}
```

Each function in the list can be either synchronous or asynchronous (`Future`).  
They are all awaited before the server becomes ready.

## Example Usage

Suppose you have some initialization tasks like preparing a database or initializing a logger:

```dart
Future<void> prepareDatabase() async {
  // Run database migrations here
}

void initializeLogger() {
  // Set up your logging system
}

@Bean()
Future<InitializationSettings> boot() async {
  return InitializationSettings.load([
    prepareDatabase,
    initializeLogger,
  ]);
}
```

In this case:
- `prepareDatabase` runs and waits for completion.
- `initializeLogger` runs immediately since it is synchronous.
- Only if all tasks succeed will the server start.

## Error Handling

- If any function throws an exception, the error and stack trace are **printed to the console**.
- The server **will not start** if initialization fails.

Example log output on failure:

```
Error starting functions: DatabaseException: Migration failed
StackTrace: ...
```

This ensures your application never runs in a partially initialized or unstable state.