import 'dart:async';

import 'package:vaden/vaden.dart';
import 'package:vaden/vaden_openapi.dart' hide Response;

@Controller('/docs')
class OpenAPIController {
  final SwaggerUI swaggerUI;
  final ApplicationSettings settings;

  const OpenAPIController(this.swaggerUI, this.settings);

  @Get('/')
  FutureOr<Response> getSwagger(Request request) {
    if (settings['openapi']['enable'] == true) {
      return swaggerUI.call(request);
    }

    return Response.notFound('Not Found');
  }

  @Get('/openapi.json')
  Response getOpenApiJSON(Request request) {
    return Response.ok(swaggerUI.schemaText, headers: {
      'Content-Type': 'application/json',
    });
  }
}
