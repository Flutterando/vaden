# Vaden - Open Issues

> Last updated: 2026-03-17
> Repository: https://github.com/Flutterando/vaden

---

## Bugs

### #153 - [BUG] Compilation errors with `@Body()` on primitive types

- **Author:** KlayRodrigs (Klayvert)
- **Labels:** bug
- **Severity:** Critical | **Priority:** P1
- **Date:** 2026-03-09

#### Description

Using `@Body()` with a primitive type (e.g. `int`) in a controller endpoint causes the generated `vaden_application.dart` to produce broken code. The generated code shadows the `request` variable and calls `.validate()` on `Request` instead of the deserialized body.

#### Steps to Reproduce

1. Create a controller with a `@Post` endpoint using `@Body() int request`:

```dart
@Controller('/api/route-stops')
class RouteBusStopsController {
  final RouteBusStopsService service;

  RouteBusStopsController({required this.service});

  @Post('/route')
  Future<int> returnInt(@Body() int request) async {
    return await service.returnIntService(routeId: request);
  }
}
```

2. Run `dart run build_runner build`
3. Try to run `bin/server.dart`

#### Errors

```
lib/vaden_application.dart:178:32: Error: Local variable 'request' can't be referenced before it is declared.
      final bodyString = await request.readAsString();
                               ^^^^^^^

lib/vaden_application.dart:180:13: Context: This is the declaration of the variable 'request'.
      final request = _injector.get<DSON>().fromJson<int>(bodyJson) as dynamic;
            ^^^^^^^

lib/vaden_application.dart:190:35: Error: The method 'validate' isn't defined for the type 'Request'.
        final validator = request.validate(ValidatorBuilder<int>());
                                  ^^^^^^^^

lib/vaden_application.dart:201:43: Error: The argument type 'Request' can't be assigned to the parameter type 'int'.
      final result = await ctrl.returnInt(request);
                                          ^
```

#### Root Cause

The code generator uses the parameter name `request` for the deserialized body, which shadows the shelf `Request request` parameter. Additionally, it tries to call `.validate()` on primitive types which don't support validation.

#### Affected Package

`vaden_class_scanner` - `BackendVadenBuilder` code generation

---

### #152 - [BUG] Enums in separate files not imported in generated code - RESOLVED

- **Author:** KlayRodrigs (Klayvert)
- **Labels:** bug
- **Date:** 2026-03-08
- **Status:** Resolved in PR [#155](https://github.com/Flutterando/vaden/pull/155) (branch `fix/152-enum-imports-generated-code`)

#### Description

The `vaden_class_scanner` build runner does not import enum types in the generated `vaden_application.dart` when enums are defined in separate files. This causes compilation errors when enums are organized in their own directories (e.g. `lib/src/enum/`).

#### Problem Flow

1. Enum defined in a separate file (e.g. `lib/src/enum/day_period_enum.dart`)
2. DTO uses the enum as a field type
3. Controller uses the enum as a parameter
4. Build runner generates code **without** importing the enum
5. Compilation error: `Undefined name`

#### Example

Enum file:
```dart
// lib/src/enum/day_period_enum.dart
enum DayPeriod {
  morning,
  afternoon,
  evening;

  static DayPeriod fromString(String value) {
    return DayPeriod.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid DayPeriod: $value'),
    );
  }
}
```

DTO using enum:
```dart
@DTO()
class BusStopDto {
  final int id;
  final DayPeriod dayPeriod;  // Uses the enum
  // ...
}
```

Controller with enum parameter:
```dart
@Get("/by-day-period/<dayPeriod>")
Future<List<BusStopDto>> getByDayPeriod(@Param() DayPeriod dayPeriod) async {
  // ...
}
```

Generated code (broken):
```dart
// lib/vaden_application.dart - GENERATED
// MISSING IMPORTS:
// import 'package:oxe_bus_api/src/enum/day_period_enum.dart';

final dayPeriod = _parse<DayPeriod>(request.params['dayPeriod'])!;
// Error: Undefined name 'DayPeriod'
```

#### Workaround

Move enums into the same file as the DTOs that use them.

#### Affected Package

`vaden_class_scanner` - import resolution logic

#### Resolution

Fixed in `vaden_class_scanner/lib/src/setups/initial.dart` by adding type import collection during code generation. Three helpers were added:
- `_collectFieldTypeImports` — scans DTO/controller fields (including inherited) for non-core types
- `_collectMethodParamTypeImports` — scans controller method params/return types (including inherited methods)
- `_addTypeImport` — resolves library URI for a type, unwraps generics (`List<T>`, `Future<T>`), skips `dart:core`

These run in `_selectComponent` after processing DTOs and Controllers, ensuring all referenced types get their imports added to the generated file.

---

## Code Quality

### #150 - Replace `print(e)`/`print(stack)` with logging package

- **Author:** Barba2k2 (Lorenzo DZ)
- **Date:** 2026-03-08

#### Description

The generated `vaden_application.dart` uses raw `print(e)` and `print(stack)` in the global exception handler:

```dart
} catch (e, stack) {
  print(e);
  print(stack);
  return _handleException(e);
}
```

This produces noisy, unformatted stack traces for every caught exception, including expected ones like auth failures (400/401).

#### Proposed Solution

Use the official `logging` package:

```dart
import 'package:logging/logging.dart';

final _logger = Logger('VadenApp');

// ...
} catch (e, stack) {
  _logger.severe('Unhandled exception', e, stack);
  return _handleException(e);
}
```

#### Benefits

- Structured output with timestamps, log levels, and source names
- Filterable by log level
- Consistent with Dart ecosystem standard
- Configurable log handlers (file, remote, formatted console)

#### Alternative

At minimum, skip printing stack traces for exceptions handled by `@ControllerAdvice` (e.g. `ResponseException`, `DioException`).

#### Affected Package

`vaden_class_scanner` - `BackendVadenBuilder` generated code template

---

## Dependency Constraints

### #154 - Widen `analyzer` constraint to support drift 2.32+

- **Author:** Barba2k2 (Lorenzo DZ)
- **Date:** 2026-03-17

#### Description

`vaden_class_scanner 1.0.2` pins `analyzer` to `">=8.0.0 <9.0.0"`, which conflicts with `drift_dev >=2.32.0` that requires `analyzer ^10.0.0`.

```
Because vaden_class_scanner 1.0.2 depends on analyzer ^8.0.0,
  vaden_class_scanner ^1.0.2 requires analyzer ^8.0.0.
And because drift_dev >=2.32.0 depends on analyzer ^10.0.0,
  vaden_class_scanner ^1.0.2 is incompatible with drift_dev >=2.32.0.
```

#### Current Constraint

```yaml
# vaden_class_scanner/pubspec.yaml
analyzer: ">=8.0.0 <9.0.0"
```

#### Suggested Fix

```yaml
analyzer: ">=8.0.0 <13.0.0"
```

Or, if the API surface used is stable:

```yaml
analyzer: ">=8.0.0"
```

The same issue may also apply to `source_gen`, `build`, and `dart_style` if their constraints are similarly narrow.

#### Workaround

Downgrade `drift` to `^2.31.0` which still uses `analyzer ^8.0.0`.

#### Environment

- Dart SDK: 3.10.0
- vaden_class_scanner: 1.0.2
- drift_dev: 2.32.0 (desired)

---

## Feature Requests

### #104 - [FEATURE] Migrations

- **Author:** auguzsto (Matheus Augusto)
- **Labels:** enhancement
- **Date:** 2025-05-28

#### Description

Database migration versioning for relational databases.

#### Objective

Enable native schema versioning and migration management through Vaden for relational databases, eliminating the need for external migration tools.

---

### #101 - [TASK] Auto-download and select driver by environment

- **Author:** marcosdanielr (Marcos Roque)
- **Assignee:** umpedetiago (Tiago Pinheiro)
- **Date:** 2025-05-26

#### Description

Implement automatic download of the correct database driver library in `AnakiDriverManager` (Dart), based on operating system, processor architecture, and the driver selected by the developer.

#### Objective

Automate fetching the correct driver binary for the runtime environment so the Dart package stays lightweight without bundling all drivers.

#### Completion Criteria

- [ ] Implement OS detection (Windows, Linux, macOS) and architecture detection (x86, x64, ARM)
- [ ] Map OS/architecture/driver combinations to download URLs
- [ ] Implement automatic download of the correct library
- [ ] Create automated tests validating download behavior on different platforms

#### Execution Steps

1. Detect OS and processor architecture in Dart
2. Auto-detect preferred driver based on database URL
3. Map OS, architecture, and driver combinations to download URLs
4. Implement automatic download mechanism
5. Validate integrity of downloaded file
6. Write cross-platform tests

---

### #62 - [FEATURE] Add guide/reference/documentation links to dependencies

- **Author:** eltonsandre (Elton Andre)
- **Labels:** enhancement, triage
- **Date:** 2025-04-09

#### Description

The `GET /v1/generate/metadata` API should include links to guides, references, and documentation for each dependency in the metadata response.

#### Suggested Contract

```dart
enum LinkType {
  guide,
  reference,
  website,
  tutorial,
  specification;
}
```

```json
{
  "dependencies": [
    {
      "name": "Swagger (OpenAPI)",
      "key": "openapi",
      "tag": "DOCUMENTATION",
      "_links": [
        {
          "type": "guide",
          "href": "https://pub.dev/documentation/swagger_dart_code_generator/latest/",
          "title": "Build dart types from Swagger/OpenAPI"
        }
      ]
    }
  ]
}
```

#### Objective

Enable creation of IDE plugins (like Spring Initializr for IntelliJ/VSCode) that can generate Vaden projects directly from the IDE, with dependency documentation links available to developers.

#### Acceptance Criteria

- [ ] Metadata API returns dependency information with reference links for each dependency

#### Reference

Spring Initializr metadata API: `https://start.spring.io/metadata/client`

---

### #55 - [FEATURE] Synchronous `.zip` download in a single request

- **Author:** eltonsandre (Elton Andre)
- **Labels:** enhancement
- **Date:** 2025-04-01

#### Description

The `POST /v1/generate/starter.zip` API should return the `.zip` file synchronously in a single request, without requiring two separate API calls.

#### Suggested API

```bash
curl --request POST \
  --url https://api.vaden.dev/v1/generate/starter.zip \
  --header 'content-type: application/json' \
  --data '{
    "projectName": "demoapi",
    "projectDescription": "lorem ipsum",
    "dartVersion": "3.7.2",
    "dependencies": ["sqlite", "dio"]
  }'
```

#### Objective

Enable creation of IDE plugins that can scaffold a Vaden project in a single API call.

#### Acceptance Criteria

- [ ] API returns the `.zip` synchronously in one request

#### Reference

Spring Initializr: `https://start.spring.io/starter.zip?type=gradle-project&...`

---

### #24 - [FEATURE] Jaspr and Flutter Web integration

- **Author:** kmsbin (Kauli Sabino)
- **Labels:** enhancement
- **Date:** 2025-03-19

#### Description

Integration with Jaspr (Dart web framework) and Flutter Web to enable fullstack Dart development with Vaden as the backend. Since Jaspr already uses Shelf as its base (same as Vaden), integration is architecturally feasible.

#### Proposed API

Server-side rendered HTML with Jaspr:
```dart
@JasprView()
Component generatePaymentForm() {
  return html([
    form(action: '/send-payment-info', [
      input(type: InputType.email, []),
      button(type: ButtonType.submit, []),
    ]),
  ]);
}
```

Flutter Web embedding:
```dart
@JasprFlutterEmbedView()
Widget generateHelloWorldPage(BuildContext context) {
  return Scaffold(
    body: Center(child: Text('Hello, world!')),
  );
}
```

#### Acceptance Criteria

- [ ] Server/client rendering mode configuration
- [ ] Support for global and local style configurations, including internal routes and fonts
- [ ] Integration with Vaden's testing API

#### Impact

Would make Vaden a fullstack solution with end-to-end testing and a simplified approach to interface development.

#### References

- Jaspr docs: https://docs.jaspr.site/
- Jaspr + Flutter Web: https://docs.jaspr.site/going_further/flutter_embedding
- Jaspr backend integration: https://docs.jaspr.site/going_further/backend
- Jaspr playground: https://jasprpad.schultek.de/
