---
sidebar_position: 3
---

# Scope

The `@Scope()` annotation defines how a component is registered in the dependency injection container.

By default, classes are registered as `lazySingleton`, meaning an instance is only created the first time it is requested. You can change this behavior by passing a different `BindType` to `@Scope()`.

## Bind Types

The `BindType` enum defines the available binding types:

- `BindType.singleton`: A single instance is created and shared across the app.
- `BindType.lazySingleton` (default): A single instance is lazily created on first access.
- `BindType.instance`: A new instance is created every time it is requested.
- `BindType.factory`: Similar to `instance` but allows passing parameters at creation.

## Example

```dart
@Scope(BindType.singleton)
class DatabaseService {
  void connect() => print('Connected');
}

@Scope(BindType.instance)
class Counter {
  int count = 0;
}
````

If no type is specified, it defaults to lazySingleton:
```dart
@Serices()
@Scope()
class AuthService {}

``` 

# Constructor Injection
The container automatically resolves and injects dependencies declared in the constructor:

```dart
@Scope(BindType.singleton)
class UserService {
  final DatabaseService database;

  UserService(this.database);

  void load() {
    database.connect();
  }
}
```
As long as DatabaseService is registered, UserService will receive it.