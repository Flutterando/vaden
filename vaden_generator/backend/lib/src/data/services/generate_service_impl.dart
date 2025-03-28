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

    await fileManager.getGenerator('initial_project').generate(fileManager, tempProject, variables: {
      ...getPackageVersions(),
      'name': project.projectName,
      'description': project.projectDescription,
      'dartVersion': project.dartVersion,
    });

    return Success(project.addPath(tempProject.path));
  }

  @override
  AsyncResult<ProjectWithTempPath> addDependencies(ProjectWithTempPath project) async {
    final tempDir = Directory(project.path);

    final versions = getPackageVersions();

    for (var dependency in project.dependencies) {
      await fileManager.getGenerator(dependency.key).generate(
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
