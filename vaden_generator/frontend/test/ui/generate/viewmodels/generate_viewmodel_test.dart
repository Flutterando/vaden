import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/repositories/generate_repository.dart';
import 'package:frontend/domain/entities/dart_versions.dart';
import 'package:frontend/domain/entities/dependency.dart';
import 'package:frontend/domain/entities/metadata.dart';
import 'package:frontend/domain/entities/project.dart';
import 'package:frontend/ui/generate/viewmodels/generate_viewmodel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';

class MockGenerateRepository extends Mock implements GenerateRepository {}

class DartVersionFake extends Fake implements DartVersion {}

class DependencyFake extends Fake implements Dependency {}

class MetadataFake extends Fake implements Metadata {
  @override
  List<DartVersion> get dartVersions => [DartVersionFake()];

  @override
  DartVersion get defaultDartVersion => DartVersionFake();

  @override
  List<Dependency> get dependencies => [DependencyFake()];
}

class ProjectFake extends Fake implements Project {}

void main() {
  late GenerateRepository generateRepository;
  late GenerateViewmodel viewmodel;

  setUpAll(() {
    registerFallbackValue(ProjectFake());
  });

  setUp(() {
    generateRepository = MockGenerateRepository();
    viewmodel = GenerateViewmodel(generateRepository);
  });

  test('fetch dependencies comnand', () async {
    when(() => generateRepository.getMetadata()).thenAnswer((_) async => Success(MetadataFake()));

    await viewmodel.fetchMedatadaCommand.execute();

    expect(viewmodel.fetchMedatadaCommand.value.isSuccess, true);
    expect(viewmodel.dartVersions.isNotEmpty, true);
    expect(viewmodel.defaultDartVersion, isA<DartVersionFake>());
    expect(viewmodel.dependencies.isNotEmpty, true);
  });

  test('create project comnand', () async {
    when(() => generateRepository.createZip(any())).thenAnswer((_) async => Success(unit));

    await viewmodel.createProjectCommand.execute(ProjectFake());

    expect(viewmodel.createProjectCommand.value.isSuccess, true);
  });
}
