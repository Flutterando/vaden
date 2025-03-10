import 'dart:async';
import 'dart:convert';

import 'package:vaden/vaden.dart';

@Component()
class AuthMiddleware extends VadenMiddleware {
  @override
  FutureOr<Response> handler(Request request, Handler handler) {
    final token = request.headers['Authorization']?.replaceFirst('Bearer ', '');

    if (token == null) {
      return Response.unauthorized('Token not found');
    }

    // Fake verify (simple decode)

    final parts = token.split('.');

    if (parts.length != 3) {
      return Response.unauthorized('Invalid token');
    }

    final payloadB64 = base64Url.normalize(parts[1]);

    final payload = jsonDecode(utf8.decode(base64Url.decode(payloadB64)));

    final userId = payload['user_id'] as String;

    final changed = request.change(context: {'user_id': userId});

    return handler(changed);
  }
}
