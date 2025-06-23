import 'dart:async';

import 'package:collection/collection.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden/vaden_openapi.dart' as oapi;
import 'package:vaden_security/src/auth_controller.dart';
import 'package:vaden_security/src/global_security_middleware.dart';
import 'package:vaden_security/vaden_security.dart';

@VadenModule([
  UserDetails,
  Tokenization,
  VadenSecurityError,
  AuthController,
])
class VadenSecurity extends CommonModule<DartVadenApplication> {
  @override
  FutureOr<void> register(DartVadenApplication app) {
    final injector = app.injector;

    var pipeline = injector.get<Pipeline>();
    pipeline = pipeline.addVadenMiddleware(GlobalSecurityMiddleware(
      injector.get<JwtService>(),
      injector.tryGet<UserDetailsService>(),
      injector.get<HttpSecurity>(),
    ));

    injector.replaceInstance(pipeline);

    var openapi = injector.get<oapi.OpenApi>();

    final httpSecurity = injector.get<HttpSecurity>();

    for (final path in (openapi.paths ?? {}).keys) {
      final pathItems = openapi.paths!;
      var pathItem = pathItems[path]!;

      if (path.startsWith('/auth/')) {
        continue;
      }

      bool checkHasSecurity(String path, HttpMethod method) {
        final authorize = httpSecurity.authorizeRequests
            .firstWhereOrNull((e) => e.matches(path, method));
        return authorize != null && authorize.autheticated();
      }

      pathItem = pathItem.copyWith(
        get: pathItem.get?.copyWith(
          security: [
            ...pathItem.get?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.get))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        post: pathItem.post?.copyWith(
          security: [
            ...pathItem.post?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.post))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        put: pathItem.put?.copyWith(
          security: [
            ...pathItem.put?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.put))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        delete: pathItem.delete?.copyWith(
          security: [
            ...pathItem.delete?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.delete))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        patch: pathItem.patch?.copyWith(
          security: [
            ...pathItem.patch?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.patch))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        head: pathItem.head?.copyWith(
          security: [
            ...pathItem.head?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.head))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        options: pathItem.options?.copyWith(
          security: [
            ...pathItem.options?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.options))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
        trace: pathItem.trace?.copyWith(
          security: [
            ...pathItem.trace?.security ?? [],
            if (checkHasSecurity(path, HttpMethod.trace))
              oapi.Security(
                name: 'bearer',
                scopes: [],
              ),
          ],
        ),
      );

      final newPathItems = {...pathItems};
      newPathItems[path] = pathItem;
      openapi = openapi.copyWith(
        paths: newPathItems,
      );
    }

    openapi = openapi.copyWith.components!.call(
      securitySchemes: {
        ...openapi.components?.securitySchemes ?? {},
        'basic': oapi.SecurityScheme.http(
          scheme: oapi.HttpSecurityScheme.basic,
          description: 'Basic authentication for login',
        ),
        'bearer': oapi.SecurityScheme.http(
          scheme: oapi.HttpSecurityScheme.bearer,
          description:
              'Bearer authentication for accessing protected resources',
        ),
        'bearer-refresh': oapi.SecurityScheme.http(
          scheme: oapi.HttpSecurityScheme.bearer,
          description: 'Bearer authentication for refreshing tokens',
        ),
      },
    );

    injector.replaceInstance<oapi.OpenApi>(openapi);
  }
}
