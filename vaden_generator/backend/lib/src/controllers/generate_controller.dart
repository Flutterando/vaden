import 'package:backend/src/domain/entities/metadata.dart';
import 'package:backend/src/domain/dtos/project_link_dto.dart';
import 'package:backend/src/domain/entities/dependency.dart';
import 'package:backend/src/domain/entities/project.dart';
import 'package:backend/src/domain/entities/project_depreciated.dart';
import 'package:backend/src/domain/usecases/create_project.dart';
import 'package:backend/src/domain/usecases/get_dependencies.dart';
import 'package:backend/src/domain/usecases/get_metadata.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Generate', description: 'Generate a new project')
@Controller('/v1/generate')
class GenerateController {
  final CreateProject _createProject;
  final GetDependencies _getDependencies;
  final GetMetadata _getMetadata;

  GenerateController(
    this._createProject,
    this._getDependencies,
    this._getMetadata,
  );

  @ApiOperation(
    summary: 'Get dependencies',
    description: 'Get all dependencies',
  )
  @ApiResponse(
    200,
    description: 'Dependencies returned',
    content: ApiContent(type: 'application/json', schema: List<Dependency>),
  )
  @Get('/dependencies')
  Future<List<Dependency>> getDependencies() async {
    return await _getDependencies().getOrThrow();
  }

  @ApiOperation(summary: 'Get metadata', description: 'Get the metadata')
  @ApiResponse(
    200,
    description: 'Metadata returned',
    content: ApiContent(type: 'application/json', schema: Metadata),
  )
  @Get('/metadata')
  Future<Metadata> getMetadata() async {
    return await _getMetadata.call().getOrThrow();
  }

  @ApiOperation(summary: 'Create project', description: 'Create a new project')
  @ApiResponse(
    200,
    description: 'Return Link to download zip project',
    content: ApiContent(type: 'application/json', schema: ProjectLinkDTO),
  )
  @Post('/start')
  Future<ProjectLinkDTO> create(@Body() Project dto) async {
    return await _createProject.call(dto).getOrThrow();
  }

  @Deprecated('This root was replace to (/start)')
  @ApiOperation(summary: 'Create project', description: 'Create a new project')
  @ApiResponse(
    200,
    description: 'Return Link to download zip project',
    content: ApiContent(type: 'application/json', schema: ProjectLinkDTO),
  )
  @Post('/create')
  Future<ProjectLinkDTO> createDeprecated(@Body() ProjectDepreciated dto) async {
    final newDto = Project(
      dependenciesKeys: dto.dependencies.map((d) => d.key).toList(),
      projectName: dto.projectName,
      projectDescription: dto.projectDescription,
      dartVersion: dto.dartVersion,
    );

    return await _createProject.call(newDto).getOrThrow();
  }
}
