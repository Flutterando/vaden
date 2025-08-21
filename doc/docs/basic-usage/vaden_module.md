# VadenModule

The `@VadenModule` annotation is the cornerstone of a Vaden application's architecture, providing a powerful mechanism for organizing your project into logical, reusable, and maintainable units. It is heavily inspired by similar concepts in frameworks like NestJS and Angular.

## What is a Module?

A module is simply a class annotated with `@VadenModule`. Its primary purpose is to group related components—such as services, controllers, repositories, and even other modules—into a cohesive block of functionality.

By using modules, you can:

- Structure your application in a clear and organized way.
- Manage dependencies effectively through Vaden's dependency injection (DI) system.
- Share and reuse code across different parts of your application or even across different projects (e.g., sharing a `DomainModule` between your backend and frontend).

## Creating a Module

To create a module, simply annotate a class with `@VadenModule`. The annotation takes a list of other modules that you want to import.

### Simple Module

Here is an example of a root application module that imports other modules:

```dart
@VadenModule([
  DomainModule,
  VadenSecurity, // Imports all providers and configurations from VadenSecurity
])
class AppModule {}
```

In this example, `AppModule` is the root module of the application. It doesn't define any components of its own but acts as a container that imports `DomainModule` and `VadenSecurity`. When the application starts, Vaden's dependency injection system will automatically make all the services and configurations from the imported modules available throughout the application.

### Modules with Custom Configuration

Some modules require more complex setup logic, such as registering middleware, configuring services, or modifying the OpenAPI specification. To achieve this, you can create a module that extends `CommonModule<T>`.

The `CommonModule` class provides a `register` method that you can override to execute custom configuration logic when the application is bootstrapping.

Here is a simplified view of the `VadenSecurity` module:

```dart
// This module imports other necessary components.
@VadenModule([
  UserDetails,
  Tokenization,
  VadenSecurityError,
  AuthController,
])
class VadenSecurity extends CommonModule<DartVadenApplication> {
  // The register method is called by Vaden during app startup.
  @override
  FutureOr<void> register(DartVadenApplication app) {
    final injector = app.injector;

    // Get existing services from the injector
    var pipeline = injector.get<Pipeline>();

    // Add custom middleware
    pipeline = pipeline.addVadenMiddleware(GlobalSecurityMiddleware(...));

    // Replace the old instance with the new one
    injector.replaceInstance(pipeline);

    // ... other configuration logic
  }
}
```

Key points from this example:

- `VadenSecurity` extends `CommonModule<DartVadenApplication>`, giving it access to the application instance (`app`).
- The `@VadenModule` annotation on `VadenSecurity` lists its own internal dependencies, which will be registered before the `register` method is called.
- The `register` method allows the module to interact with the application's dependency `injector` to add, retrieve, or replace services, effectively configuring the application's runtime behavior.

## How it Works

When you run your Vaden application, a code generator processes the root module (e.g., `AppModule`) and recursively discovers all imported modules and their dependencies. It then builds a dependency injection container that knows how to instantiate and provide all the necessary services for your application.

This modular approach is fundamental to building scalable and well-architected applications with Vaden, whether for a backend server or a Flutter client.
