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
