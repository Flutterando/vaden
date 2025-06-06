import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/src/http_method.dart';
import 'package:vaden_security/src/http_security.dart';
import 'package:vaden_security/src/jwt_service.dart';
import 'package:vaden_security/src/user_details_service.dart';

class GlobalSecurityMiddleware extends VadenMiddleware {
  final JwtService jwtService;
  final UserDetailsService? userDetailsService;
  final HttpSecurity httpSecurity;

  GlobalSecurityMiddleware(
    this.jwtService,
    this.userDetailsService,
    this.httpSecurity,
  );

  @override
  FutureOr<Response> handler(Request request, Handler handler) async {
    final path = '/${request.url.path}';

    final method = HttpMethod.fromRequest(request);

    final authorize = httpSecurity.authorizeRequests //
        .firstWhereOrNull((e) => e.matches(path, method));

    if (authorize == null || authorize.isDenyAll()) {
      return Response.unauthorized(
          jsonEncode({'error': 'No authorize request found for path $path'}));
    }

    if (!authorize.autheticated()) {
      return handler(request);
    }

    final authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.toLowerCase().startsWith('bearer ')) {
      return Response.unauthorized(
          jsonEncode({'error': 'Missing or invalid Authorization header'}));
    }

    final token = authHeader.substring(7);
    final claims = jwtService.verifyToken(token);
    if (claims == null) {
      return Response.unauthorized(jsonEncode({'error': 'Invalid token'}));
    }

    final username = claims['sub']!;

    final userDetails = await userDetailsService?.loadUserByUsername(username);
    if (userDetails == null) {
      return Response.unauthorized(jsonEncode({'error': 'User not found'}));
    }

    if (!authorize.hasRole(userDetails.roles)) {
      return Response.forbidden(
          jsonEncode({'error': 'User does not have the required role'}));
    }

    final updatedRequest = request.change(context: {
      'user': userDetails,
      'roles': userDetails.roles,
    });

    return handler(updatedRequest);
  }
}
