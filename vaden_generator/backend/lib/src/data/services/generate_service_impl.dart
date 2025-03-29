import 'dart:convert';
import 'dart:io';

import 'package:backend/src/core/files/file_manager.dart';
import 'package:backend/src/domain/dtos/project_link_dto.dart';
import 'package:backend/src/domain/entities/dependency.dart';
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
    final tempProject =
        await fileManager.createTempDir(tempFolder, project.projectName);

    await fileManager
        .getGenerator('initial_project')
        .generate(fileManager, tempProject, variables: {
      ...getPackageVersions(),
      'name': project.projectName,
      'description': project.projectDescription,
      'dartVersion': project.dartVersion,
    });

    return Success(project.addPath(tempProject.path));
  }

  @override
  AsyncResult<ProjectWithTempPath> addDependencies(
      ProjectWithTempPath project) async {
    final tempDir = Directory(project.path);

    final versions = getPackageVersions();

    final allDependencyKey = _getAllDependenciesKeys(project.dependencies);

    for (var key in allDependencyKey) {
      await fileManager.getGenerator(key).generate(
        fileManager,
        tempDir,
        variables: {
          ...versions,
          'name': project.projectName,
          'description': project.projectDescription,
          'dartVersion': project.dartVersion,
        },
      );
    }

    return Success(project);
  }

  List<String> _getAllDependenciesKeys(List<Dependency> dependencies) {
    final dependenciesRequirements = getDependenciesRequirements();

    Set<String> allDependenciesKeys = {};
    Set<String> requirementsKeys = dependencies.map((d) => d.key).toSet();

    while (true) {
      if (requirementsKeys.isEmpty) {
        return allDependenciesKeys.toList();
      }

      Set<String> newRequirementsKeys = {};
      for (var key in requirementsKeys) {
        allDependenciesKeys.add(key);
        newRequirementsKeys.addAll(dependenciesRequirements[key]!);
      }

      requirementsKeys = newRequirementsKeys;
    }
  }

  Map<String, List<String>> getDependenciesRequirements() {
    final packageDependencies = File('assets/dependencies.json');
    final packageDependenciesContent = packageDependencies.readAsStringSync();
    final packageDependenciesList =
        jsonDecode(packageDependenciesContent) as List;

    return Map.fromEntries(packageDependenciesList.map((d) => MapEntry(d['key'],
        ((d['requirements'] ?? []) as List).map((r) => r as String).toList())));
  }

  Map<String, dynamic> getPackageVersions() {
    final packageVersion = File('assets/package_version.json');
    final packageVersionContent = packageVersion.readAsStringSync();
    final packageVersionMap =
        jsonDecode(packageVersionContent) as Map<String, dynamic>;
    return packageVersionMap;
  }

  @override
  AsyncResult<ProjectLinkDTO> createZipLink(ProjectWithTempPath project) async {
    final bytes =
        await fileManager.createZip(project.path, project.projectName);
    final link = await storage.upload('${project.projectName}.zip', bytes);
    return Success(ProjectLinkDTO(link));
  }
}
