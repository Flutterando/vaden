import 'dart:convert';
import 'dart:io';

import 'package:backend/src/core/files/file_manager.dart';
import 'package:backend/src/domain/dtos/project_link_dto.dart';
import 'package:backend/src/domain/entities/project.dart';
import 'package:backend/src/domain/services/generate_service.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

@Service()
class GenerateServiceImpl implements GenerateService {
  final FileManager fileManager;
  final Storage storage;

  GenerateServiceImpl(this.fileManager, this.storage);

  @override
  AsyncResult<ProjectWithTempPath> createTempProject(
    Project project,
    Directory tempFolder,
  ) async {
    final tempProject = await fileManager.createTempDir(tempFolder, project.projectName);

    final initialProjectGenerator = fileManager.getGenerator('initial_project');
    if (initialProjectGenerator == null) {
      return Failure(
        Exception('Gerador para projeto inicial não encontrado'),
      );
    }

    await initialProjectGenerator.generate(
      fileManager,
      tempProject,
      variables: {
        ...getPackageVersions(),
        'name': project.projectName,
        'description': project.projectDescription,
        'dartVersion': project.dartVersion,
        'dependenciesKeys': project.dependenciesKeys,
      },
    );

    return Success(project.addPath(tempProject.path));
  }

  @override
  AsyncResult<ProjectWithTempPath> addDependencies(ProjectWithTempPath project) async {
    final tempDir = Directory(project.path);
    final versions = getPackageVersions();

    final allDependencies = _getAllDependenciesKeys(project.dependenciesKeys);

    for (var key in allDependencies) {
      if (key != 'vaden_security' && key != 'initial_project') {
        final generator = fileManager.getGenerator(key);
        if (generator != null) {
          await generator.generate(
            fileManager,
            tempDir,
            variables: {
              ...versions,
              'name': project.projectName,
              'description': project.projectDescription,
              'dartVersion': project.dartVersion,
              'dependenciesKeys': project.dependenciesKeys,
            },
          );
        }
      }
    }

    return Success(project);
  }

  List<String> _getAllDependenciesKeys(List<String> dependenciesKyes) {
    final dependenciesRequirements = getDependenciesRequirements();

    Set<String> allDependenciesKeys = {};
    Set<String> requirementsKeys = dependenciesKyes.toSet();

    while (true) {
      if (requirementsKeys.isEmpty) {
        return allDependenciesKeys.toList();
      }

      Set<String> newRequirementsKeys = {};
      for (var key in requirementsKeys) {
        if (dependenciesRequirements[key] != null) {
          allDependenciesKeys.add(key);
          newRequirementsKeys.addAll(dependenciesRequirements[key]!);
        }
      }

      requirementsKeys = newRequirementsKeys;
    }
  }

  Map<String, List<String>> getDependenciesRequirements() {
    final packagMetadata = File('assets/metadata.json');
    final packagMetadataContent = packagMetadata.readAsStringSync();
    final metadata = jsonDecode(packagMetadataContent) as Map;

    return Map.fromEntries(
      (metadata['dependencies'] as List).map(
        (d) => MapEntry(
          d['key'],
          ((d['requirements'] ?? []) as List).cast<String>(),
        ),
      ),
    );
  }

  Map<String, dynamic> getPackageVersions() {
    final packageVersion = File('assets/package_version.json');
    final packageVersionContent = packageVersion.readAsStringSync();
    final packageVersionMap = jsonDecode(packageVersionContent) as Map<String, dynamic>;
    return packageVersionMap;
  }

  @override
  AsyncResult<ProjectLinkDTO> createZipLink(ProjectWithTempPath project) async {
    final bytes = await fileManager.createZip(project.path, project.projectName);
    final link = await storage.upload('${project.projectName}.zip', bytes);
    return Success(ProjectLinkDTO(link));
  }
}
