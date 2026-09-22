import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:test/test.dart';
import 'package:vaden_class_scanner/src/flutter_builder.dart';

/// Runs [FlutterVadenBuilder] against a single fixture file and returns the
/// generated `lib/vaden_application.dart` contents.
///
/// `vaden_core` (used by the `@ApiClient`/`@DTO` imports in the fixtures)
/// isn't part of the in-memory sourceAssets, so it needs to be loaded from
/// the real package resolution of the current isolate for the analyzer to
/// resolve it.
Future<TestBuilderResult> _runBuilder(String fixturePath) async {
  final fixtureSource = File(fixturePath).readAsStringSync();
  final fixtureFileName = fixturePath.split('/').last;

  final readerWriter = TestReaderWriter(rootPackage: 'pkg');
  await readerWriter.testing.loadIsolateSources();
  readerWriter.testing.writeString(
    AssetId('pkg', 'lib/$fixtureFileName'),
    fixtureSource,
  );

  return testBuilder(
    FlutterVadenBuilder(),
    {},
    rootPackage: 'pkg',
    readerWriter: readerWriter,
    flattenOutput: true,
  );
}

void main() {
  test(
    '@ApiClient classes are registered via their generated implementation '
    'instead of tearing off the abstract constructor (regression for #139)',
    () async {
      final result = await _runBuilder('test/fixtures/api_client_fixture.dart');

      final output = result.readerWriter.testing.readString(
        AssetId('pkg', 'lib/vaden_application.dart'),
      );

      // Bug from #139: the abstract class constructor was torn off directly,
      // which fails to compile because LaunchApi is abstract.
      expect(output, isNot(contains('_injector.addLazySingleton(LaunchApi.new)')));

      // Fixed in #144: the class is registered via its generated
      // implementation instead.
      expect(
        output,
        contains('_injector.addLazySingleton<LaunchApi>(_LaunchApi.new)'),
      );
      expect(output, contains('class _LaunchApi implements LaunchApi'));
    },
  );

  test(
    'builder succeeds and emits no @ApiClient boilerplate when the package '
    'has no @ApiClient classes',
    () async {
      final result = await _runBuilder('test/fixtures/fixture_dtos.dart');

      expect(result.succeeded, isTrue, reason: result.errors.join('\n'));

      final output = result.readerWriter.testing.readString(
        AssetId('pkg', 'lib/vaden_application.dart'),
      );

      expect(output, contains('class _DSON extends DSON'));
      expect(output, isNot(contains('implements LaunchApi')));
      expect(output, isNot(contains('LaunchApi')));
    },
  );
}
