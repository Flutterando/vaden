---
sidebar_position: 8
---

# Exception Handling

Vaden includes a powerful exception handling mechanism inspired by Spring Boot’s `@ControllerAdvice`. It allows you to define global error handling logic in a centralized and reusable way.

## ControllerAdvice

Classes annotated with `@ControllerAdvice()` act as global interceptors for uncaught exceptions that occur during request processing.

Each method inside this class can be annotated with `@ExceptionHandler(SomeException)` to catch and handle a specific type of exception.
You can inject dependencies into the advice class like any other component.

```dart
@ControllerAdvice()
class AppControllerAdvice {
  final DSON _dson;
  AppControllerAdvice(this._dson);

  @ExceptionHandler(ResponseException)
  Future<Response> handleResponseException(ResponseException e) async {
    return e.generateResponse(_dson);
  }

  @ExceptionHandler(Exception)
  Response handleGeneric(Exception e) {
    return Response.internalServerError(
      body: jsonEncode({'message': 'Internal server error'}),
    );
  }
}
```

- The first method catches `ResponseException` and uses a custom method to generate a response.
- The second method handles any uncaught Exception as a fallback.

## Design Notes

- All `@ExceptionHandler()` methods must return Response or `Future<Response>`.
- You can have multiple `@ControllerAdvice()` classes if needed.
- The closest match (based on type hierarchy) will be used.
- Dependency injection is fully supported.

This exception handling system gives you clean, centralized control over error formatting, status codes, and custom logic without scattering try/catch blocks throughout your controllers.