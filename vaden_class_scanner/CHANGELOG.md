## 1.0.0 (2025/11/16)
- Release!
- Class Scanner 4x mais rápido.
- Atualizado builder para 4.0.0.
- Correções de bugs.
- Refatorações no class_scanner.
- Remove build_runner mirrors.


## 0.1.4 (2025/10/05)
- Fix @Body list and Swagger nullsafety

## 0.1.3 (2025/08/21)

- Fix DTO serialization

## 0.1.2 (2025/07/20)

- Added Scope to Dependency Injection.
- Support unionType.


## 0.1.1 (2025/06/23)

- Fix [flutter_vaden] @ApiClient() basePath;

## 0.1.0 (2025/06/22)

- Added New Core


## 0.0.12 (2025/04/28)

- Added Parse.
- Fix primitive nullable list.
- Added ApplicationRunner and CommandLineRunner.

- `server.dart` changes:
```dart
Future<void> main(List<String> args) async {
  final vaden = VadenApplicationImpl();
  await vaden.setup();
  final server = await vaden.run(args);
  print('Server listening on port ${server.port}');
}
```

## 0.0.11 (2025/04/14)

- Added ResponseEntity
- Added VadenModule annotation

## 0.0.8 (2025/03/28)

- Fix DSON serialization.
- Fix OpenAPI Header.

## 0.0.7 (2025/03/28)
- Fix abstract Controller methods.
- Fix Complex object parse.

## 0.0.6

- Initial version.
