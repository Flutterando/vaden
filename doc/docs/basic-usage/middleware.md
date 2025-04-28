---
sidebar_position: 4
---

# Middleware

Vaden offers a powerful middleware system that builds on top of the Shelf pipeline. It allows request/response transformations, authentication, logging, header manipulation, and more — globally or per route.

## Global Middlewares with `Pipeline`

To define middlewares that apply to all requests, use the Pipeline inside your `@Configuration()` class:

```dart
@Configuration()
class AppConfiguration {
  @Bean()
  ApplicationSettings settings() {
    return ApplicationSettings.load('application.yaml');
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

- `addMiddleware(...)` adds any Shelf middleware.
- `addVadenMiddleware(...)` adds a Vaden-compatible middleware.

These middlewares are executed before any controller logic.

## Route-Level Middleware

You can apply middleware to specific controllers or even individual routes using the `@UseMiddleware` annotation:

```dart
@UseMiddleware([LoggerMiddleware])
@Controller('/users')
class UserController {
  @Get('/')
  Response list() => Response.ok('Users');
}
```

You can also annotate a specific method:

```dart
@UseMiddleware([LoggerMiddleware])
@Get('/profile')
Response getProfile() => Response.ok('Profile');
```

Middleware classes must implement the following interface:

```dart
class MyMiddleware implements VadenMiddleware {
  FutureOr<Response> handle(Request request, Handler next) async {
    return next(request);
  }
}
```

## Guards

Guards are a special kind of middleware used for access control. You can apply them just like regular middleware using `@UseGuards`.

```dart
@UseGuards([AuthGuard])
@Controller('/admin')
class AdminController {
  @Get('/dashboard')
  Response dashboard() => Response.ok('Admin');
}
```

A guard must extend `Guard`, which itself implements `Middleware`:

```dart
class MyGuard extends VadenGuard {
  FutureOr<bool> canActivate(Request request) async {
    return true;
  }
}
```

## Middleware Order

Middleware execution order follows this pattern:

- Global middlewares from Pipeline in `AppConfiguration`.
- Controller-level `@UseMiddleware`.
- Method-level `@UseMiddleware`.
- Guards via `@UseGuards` are always applied before any other route logic.

This layered approach ensures clear separation of concerns and flexible request control.
