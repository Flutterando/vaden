import 'dart:convert';

import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Api(tag: 'Auth', description: 'Authentication and authorization endpoints')
@Controller('/auth')
class AuthController {
  final JwtService jwtService;
  final UserDetailsService userDetailsService;
  final PasswordEncoder passwordEncoder;

  AuthController(
    this.jwtService,
    this.userDetailsService,
    this.passwordEncoder,
  );

  @ApiSecurity(['bearer'])
  @ApiOperation(summary: 'Get current user details')
  @ApiResponse(200,
      description: 'User details retrieved successfully',
      content: ApiContent(type: 'application/json', schema: UserDetails))
  @ApiResponse(403,
      description: 'Forbidden',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(400,
      description: 'Bad request',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(500,
      description: 'Internal server error',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(401,
      description: 'Unauthorized',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @Get('/me')
  Future<UserDetails> me(@Header('Authorization') String? header) async {
    if (header == null || !header.toLowerCase().startsWith('bearer ')) {
      throw ResponseException(
          400, VadenSecurityError('Missing or invalid Authorization header'));
    }
    final token = header.substring(7);

    final claims = jwtService.verifyToken(token);
    if (claims == null) {
      throw ResponseException(401, VadenSecurityError('Invalid token'));
    }
    final username = claims['sub'];
    if (username == null) {
      throw ResponseException(403, VadenSecurityError('Token missing subject'));
    }
    final userDetails = await userDetailsService.loadUserByUsername(username);
    if (userDetails == null) {
      throw ResponseException(403, VadenSecurityError('Invalid credentials'));
    }

    return userDetails;
  }

  @ApiSecurity(['basic'])
  @ApiOperation(summary: 'Login and get access and refresh tokens')
  @ApiResponse(200,
      description: 'Tokens retrieved successfully',
      content: ApiContent(type: 'application/json', schema: Tokenization))
  @ApiResponse(403,
      description: 'Forbidden',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(400,
      description: 'Bad request',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(500,
      description: 'Internal server error',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(401,
      description: 'Unauthorized',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @Get('/login')
  Future<Tokenization> login(@Header('Authorization') String? basic) async {
    if (basic == null || !basic.toLowerCase().startsWith('basic ')) {
      throw ResponseException(
          400, VadenSecurityError('Missing or invalid Authorization header'));
    }
    final encodedCredentials = basic.substring(6);
    final decodedCredentials = utf8.decode(base64.decode(encodedCredentials));
    final credentials = decodedCredentials.split(':');
    if (credentials.length != 2) {
      throw ResponseException(
          400, VadenSecurityError('Invalid credentials format'));
    }
    final username = credentials[0];
    final rawPassword = credentials[1];
    if (username.isEmpty || rawPassword.isEmpty) {
      throw ResponseException(
          400, VadenSecurityError('Missing username or password'));
    }

    final userDetails = await userDetailsService.loadUserByUsername(username);
    if (userDetails == null) {
      throw ResponseException(403, VadenSecurityError('Invalid credentials'));
    }

    if (!passwordEncoder.matches(rawPassword, userDetails.password)) {
      throw ResponseException(403, VadenSecurityError('Invalid credentials'));
    }

    final token = jwtService.generateToken(userDetails);

    return token;
  }

  @ApiSecurity(['bearer-refresh'])
  @ApiOperation(summary: 'Refresh access token using refresh token')
  @ApiResponse(200,
      description: 'Tokens refreshed successfully',
      content: ApiContent(type: 'application/json', schema: Tokenization))
  @ApiResponse(403,
      description: 'Forbidden',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(400,
      description: 'Bad request',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(500,
      description: 'Internal server error',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @ApiResponse(401,
      description: 'Unauthorized',
      content: ApiContent(type: 'application/json', schema: VadenSecurityError))
  @Get('/refresh')
  Future<Tokenization> register(@Header('Authorization') String? header) async {
    if (header == null || !header.toLowerCase().startsWith('bearer ')) {
      throw ResponseException(
          400, VadenSecurityError('Missing or invalid Authorization header'));
    }
    final refreshToken = header.substring(7);

    final claims = jwtService.verifyToken(refreshToken);
    if (claims == null || claims['refresh'] != true) {
      throw ResponseException(403, VadenSecurityError('Invalid refresh token'));
    }

    final username = claims['sub'];
    if (username == null) {
      throw ResponseException(403, VadenSecurityError('Token missing subject'));
    }

    final userDetails = await userDetailsService.loadUserByUsername(username);
    if (userDetails == null) {
      throw ResponseException(403, VadenSecurityError('Invalid credentials'));
    }

    final token = jwtService.generateToken(userDetails);

    return token;
  }
}
