---
sidebar_position: 2
---

# The `domain` Package

The `domain` package is the core of your shared code. Its primary responsibility is to define the data structures that will be used by both the frontend and backend.

## Defining Data Transfer Objects (DTOs)

DTOs are simple classes that define the shape of the data exchanged between the client and server. In Vaden, you can create them easily using the `@DTO` annotation from the `vaden_core` package.

Here's an example:

```dart
import 'package:vaden_core/vaden_core.dart';

@DTO()
class Todo {
  final int id;
  final String title;
  final bool check;

  Todo({required this.id, required this.title, required this.check});
}

@DTO()
class TodoCreate {
  final String title;
  final bool check;

  TodoCreate({required this.title, required this.check});
}
```

The `@DTO` annotation tells the Vaden code generator to create the necessary serialization and deserialization logic (`toJson`, `fromJson`), enabling these objects to be easily converted to and from JSON.

## The Domain Module

To make these DTOs available for dependency injection and serialization, you group them in a module file.

```dart
@VadenModule([
  DefaultMessage,
  Todo,
  TodoCreate,
])
class DomainModule {}
```
