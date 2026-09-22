import 'package:vaden_core/vaden_core.dart';

@ApiClient('/launch')
abstract class LaunchApi {
  @Get('/all')
  Future<List<String>> getAll();

  @Get('/<id>')
  Future<String> getById(@Param() String id);
}
