import 'package:example/src/auth_middleware.dart';
import 'package:example/src/auth_service.dart';
import 'package:vaden/vaden.dart';

import 'auth_guard.dart';
import 'credentials.dart';
import 'tokenization.dart';

@Api(tag: 'auth', description: 'Auth API')
@Controller('/auth')
class AuthControllar {
  final AuthService _authService;

  AuthControllar(this._authService);

  @UseGuards([AuthGuard])
  @Get('/ping')
  Future<Response> ping() async {
    return Response.ok(_authService.ping());
  }

  @Get('/other/<id>')
  Future<Response> other(@Param('id') String id) async {
    return Response.ok('other $id');
  }

  @ApiSecurity(['bearer'])
  @ApiOperation(
    summary: 'Faz login de usuário',
    description: 'Valida as credenciais e retorna um token de sessão',
  )
  @ApiResponse(
    200,
    description: 'Usuário autenticado com sucesso',
    content: ApiContent(type: 'application/json', schema: Tokenization),
  )
  @ApiResponse(401, description: 'Credenciais inválidas')
  @Post('/login')
  Future<Response> login(
    @Body() Credentials credentials,
  ) async {
    return Response.ok(credentials);
  }

  @UseMiddleware([AuthMiddleware])
  @Post('/sign-out')
  Future<Response> signOut(@Context('user_id') String userId) async {
    return Response.ok('Deslogando do usuário $userId!');
  }

  @Post('/refresh-token')
  Future<Response> refreshToken(@Header('Authorization') String? token) async {
    if (token == null) {
      return Response.unauthorized('Token not found');
    }

    return Response.ok('Token recuperado do header: ${token.replaceFirst('Bearer ', '')}');
  }
}
