import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:vaden_class_scanner/src/setups/dto_setup.dart';

void main() {
  group('computeRequiredFieldsForTest (integration)', () {
    late LibraryElement library;

    setUpAll(() async {
      final root = Directory.current.path;
      final fixturePath = p.join(root, 'test', 'fixtures', 'fixture_dtos.dart');
      final collection = AnalysisContextCollection(includedPaths: [root]);
      final context = collection.contextFor(fixturePath);
      final session = context.currentSession;
      final result =
          await session.getResolvedUnit(fixturePath) as ResolvedUnitResult;
      library = result.libraryElement;
    });

    ClassElement find(String name) {
      final units = <CompilationUnitElement>[
        library.definingCompilationUnit,
        ...library.parts,
      ];
      for (final unit in units) {
        for (final cls in unit.classes) {
          if (cls.name == name) return cls;
        }
      }
      throw StateError('Class $name not found');
    }

    test('A: required id, optional alias_optional, nullable note', () {
      final classA = find('A');
      final requiredA = computeRequiredFieldsForTest(classA);
      expect(requiredA, contains('id'));
      expect(requiredA, isNot(contains('alias_optional')));
      expect(requiredA, isNot(contains('note')));
    });

    test('B: forced required true', () {
      final classB = find('B');
      final requiredB = computeRequiredFieldsForTest(classB);
      expect(requiredB, contains('forced'));
    });

    test('C: default + required:false keeps alias_c optional', () {
      final classC = find('C');
      final requiredC = computeRequiredFieldsForTest(classC);
      expect(requiredC, isNot(contains('alias_c')));
    });
  });
}
