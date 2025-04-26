import 'dart:io';

import 'package:backend/src/domain/dtos/project_link_dto.dart';
import 'package:backend/src/domain/entities/project.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class GenerateService {
  AsyncResult<ProjectWithTempPath> createTempProject(
    Project project,
    Directory tempFolder,
  );
  AsyncResult<ProjectWithTempPath> addDependencies(ProjectWithTempPath project);
  AsyncResult<ProjectLinkDTO> createZipLink(ProjectWithTempPath project);
}
