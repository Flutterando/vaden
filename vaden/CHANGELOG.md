

## 1.0.2 (2025/11/16)
- Fix Json Default Value

## 1.0.0 (2025/11/16)
- Release!
- Class Scanner 4x mais rápido.
- Atualizado builder para 4.0.0.
- Correções de bugs.
- Refatorações no class_scanner.

## 0.1.2 (2025/08/21)

- Fix DTO nullable serialization.

## 0.1.1 (2025/07/20)

- Added Scope to Dependency Injection.
- Support unionType.


## 0.1.0 (2025/06/22)

- New Core

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

## 0.0.10 (2025/04/14)

- Added ResponseEntity
- Added VadenModule annotation

## 0.0.9 (2025/04/11)

- Added RegisterModule

## 0.0.8 (2025/03/28)

- Fix DSON serialization.
- Fix OpenAPI Header.

## 0.0.7 (2025/03/28)
- Fix abstract Controller methods.
- Fix Complex object parse.

## 0.0.6

- Start ALPHA


## 0.0.1

- Initial version.
