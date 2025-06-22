import 'dart:convert';

import 'package:vaden/vaden.dart';
import 'package:vaden/vaden_openapi.dart';

@Configuration()
class OpenApiConfiguration {
  @Bean()
  OpenApi openApi(OpenApiConfig config) {
    return OpenApi(
      version: '3.0.0',
      info: Info(
        title: 'Vaden API',
        version: '1.0.0',
        description: 'Vaden Backend example',
      ),
      servers: [
        config.localServer,
      ],
      tags: config.tags,
      paths: config.paths,
      components: Components(
        schemas: config.schemas,
        securitySchemes: {
          'bearer': SecurityScheme.http(
            scheme: HttpSecurityScheme.bearer,
            bearerFormat: 'JWT',
            description: 'Bearer token for authentication',
          ),
        },
      ),
    );
  }

  @Bean()
  SwaggerUI swaggerUI(OpenApi openApi) {
    return SwaggerUI(
      jsonEncode(openApi.toJson()),
      title: 'project_t API',
      docExpansion: DocExpansion.list,
      deepLink: true,
      persistAuthorization: false,
      syntaxHighlightTheme: SyntaxHighlightTheme.agate,
    );
  }
}
