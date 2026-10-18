# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vaden is a Dart backend framework inspired by Spring Boot, built by the Flutterando community. It uses annotation-based controllers, dependency injection (via `auto_injector`), middlewares, guards, DTOs, and OpenAPI documentation on top of the Shelf HTTP server.

Docs: https://doc.vaden.dev | Project generator: https://start.vaden.dev

## Workspace Structure

This is a Dart workspace (SDK ^3.9.2) with these packages:

| Package | Path | Purpose |
|---|---|---|
| **vaden** | `vaden/` | Core framework: annotations, shelf integration, middleware, guards, storage, OpenAPI |
| **vaden_core** | `vaden_core/` | Shared annotations and types used by both backend and Flutter packages |
| **vaden_class_scanner** | `vaden_class_scanner/` | `build_runner` code generator that scans annotations and generates `vaden_application.dart` |
| **flutter_vaden** | `flutter_vaden/` | Flutter client-side package (Dio-based HTTP, DI) |
| **vaden_security** | `packages/vaden_security/` | JWT auth, password encoding, security middleware |
| **vaden_mcp** | `vaden_mcp/` | MCP server for project introspection and code generation |
| **vaden_generator backend** | `vaden_generator/backend/` | Backend for start.vaden.dev (project scaffolding service) |
| **vaden_generator frontend** | `vaden_generator/frontend/` | Flutter web frontend for start.vaden.dev |
| **example** | `vaden/example/` | Reference Vaden backend application |
| **todo example** | `examples/todo/` | Full-stack todo app (app + backend + shared domain) |

## Build & Development Commands

```bash
# Install all workspace dependencies
dart pub get

# Run code generation (generates vaden_application.dart from annotations)
# Must be run from a package that uses vaden_class_scanner (e.g., vaden/example/)
cd vaden/example && dart run build_runner build --delete-conflicting-outputs

# Run tests for a specific package
cd vaden && dart test
cd vaden_class_scanner && dart test
cd packages/vaden_security && dart test
cd vaden_mcp && dart test

# Run a single test file
cd vaden && dart test test/injector_test.dart

# Analyze/lint a package
cd vaden && dart analyze

# Run the example server
cd vaden/example && dart run bin/server.dart

# Run the generator backend
cd vaden_generator/backend && dart run bin/backend.dart
```

## Code Generation Architecture

The central architectural pattern is **annotation scanning + code generation**:

1. Developers annotate classes with `@Controller`, `@Service`, `@Repository`, `@DTO`, `@Configuration`, etc. (defined in `vaden_core`)
2. `vaden_class_scanner` is a `build_runner` builder that scans all `.dart` files for these annotations
3. It generates `lib/vaden_application.dart` containing the `VadenApp` class with:
   - All DI registrations in `setup()`
   - Router bindings for controllers
   - DSON (DTO serialization) class
   - Exception handler dispatch from `@ControllerAdvice`
4. The builder has two targets: `BackendVadenBuilder` (default) and `FlutterVadenBuilder` (set via `build.yaml` options `target: flutter`)

**The generated `vaden_application.dart` is committed to source** (`build_to: source`). After modifying annotations, re-run `build_runner build`.

## Key Annotations (from vaden_core)

- `@Controller('/path')` - REST controller with base path
- `@Get`, `@Post`, `@Put`, `@Delete`, `@Patch`, `@Head`, `@Options` - HTTP method handlers
- `@Mount('/path')` - Mount a sub-router
- `@Service()`, `@Repository()`, `@Component()` - DI-managed classes (register by interface by default)
- `@Configuration()` + `@Bean()` - Factory methods for DI
- `@DTO()` - Data transfer objects with auto-generated `fromJson`/`toJson` via DSON
- `@Body()`, `@Query()`, `@Param()`, `@Header()`, `@Context()` - Parameter binding
- `@UseMiddleware([...])`, `@UseGuards([...])` - Middleware/guard application
- `@ControllerAdvice()` + `@ExceptionHandler(Type)` - Global exception handling
- `@Scope(BindType.singleton)` - DI scope control
- `@VadenModule([...])` - Module imports
- `@JsonKey('name')`, `@JsonIgnore()`, `@JsonDefault(value)` - DTO field customization
- `@Parse()` + `@UseParse(ParserType)` - Custom field serialization
- `@ApiClient()` - Flutter-side API client generation

## Application Lifecycle

```
main() → VadenApp() → setup() → run(args)
```

- `setup()`: registers DI bindings, configures routes, initializes DSON, runs async beans
- `run()`: starts shelf HTTP server using `ApplicationSettings` from YAML config
- Config loaded via `ApplicationSettings.load('config.yaml')` with `settings['server']['port']`

## Framework Extension Points

- **Guard**: extend `VadenGuard`, implement `canActivate(Request) → bool`
- **Middleware**: extend `VadenMiddleware`, implement `handler(Request, Handler) → Response`
- **Validator**: use `lucid_validation` integration
- **Storage**: `LocalStorage`, `AwsS3Storage`, `FirebaseStorage` abstractions
- **DSON**: auto-generated serialization registry for all `@DTO` classes
