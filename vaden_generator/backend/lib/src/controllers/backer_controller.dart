import 'package:backend/src/domain/entities/backer.dart';
import 'package:backend/src/domain/repositories/backer_repository.dart';
import 'package:result_dart/result_dart.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'backer', description: 'Sponsor')
@Controller('/v1/backer')
class BackerController {
  final BackerRepository _backerRepository;
  BackerController(this._backerRepository);

  @ApiOperation(summary: 'Check backer')
  @ApiResponse(
    200,
    description: 'Check backer',
    content: ApiContent(type: 'application/json', schema: Backer),
  )
  @Get('/check/<email>')
  Future<Backer> getDependencies(@Param() String email) async {
    return await _backerRepository.check(email).getOrThrow();
  }
}
