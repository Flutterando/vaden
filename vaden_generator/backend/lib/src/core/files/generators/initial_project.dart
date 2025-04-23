import 'dart:io';

import 'package:backend/src/core/files/file_generate.dart';
import 'package:backend/src/core/files/file_manager.dart';

class InitialProjectGenerator extends FileGenerator {
  @override
  Future<void> generate(
    FileManager fileManager,
    Directory directory, {
    Map<String, dynamic> variables = const {},
  }) async {
    final pubspec = File('${directory.path}${Platform.pathSeparator}pubspec.yaml');
    await pubspec.create(recursive: true);
    await pubspec.writeAsString(parseVariables(_pubspecContent, variables));

    final readme = File('${directory.path}${Platform.pathSeparator}README.md');
    await readme.create(recursive: true);
    await readme.writeAsString(parseVariables(_readmeContent, variables));

    final build = File('${directory.path}${Platform.pathSeparator}build.yaml');
    await build.create(recursive: true);
    await build.writeAsString(_buildContent);

    final application = File('${directory.path}${Platform.pathSeparator}application.yaml');
    await application.create(recursive: true);
    await application.writeAsString(parseVariables(_applicationContent, variables));

    final dockerFile = File('${directory.path}${Platform.pathSeparator}Dockerfile');
    await dockerFile.create(recursive: true);
    await dockerFile.writeAsString(_dockerFileContent);

    final analysisOptions = File('${directory.path}${Platform.pathSeparator}analysis_options.yaml');
    await analysisOptions.create(recursive: true);
    await analysisOptions.writeAsString(_analysisOptionsContent);

    final gitIgnore = File('${directory.path}${Platform.pathSeparator}.gitignore');
    await gitIgnore.create(recursive: true);
    await gitIgnore.writeAsString(_gitIgnoreContent);

    final dockerIgnore = File('${directory.path}${Platform.pathSeparator}.dockerignore');
    await dockerIgnore.create(recursive: true);
    await dockerIgnore.writeAsString(_dockerIgnoreContent);

    final publicIndex = File(
      '${directory.path}${Platform.pathSeparator}public${Platform.pathSeparator}index.html',
    );
    await publicIndex.create(recursive: true);
    await publicIndex.writeAsString(parseVariables(_publicIndexContent, variables));

    final binServer = File(
      '${directory.path}${Platform.pathSeparator}bin${Platform.pathSeparator}server.dart',
    );
    await binServer.create(recursive: true);
    await binServer.writeAsString(parseVariables(_binServerContent, variables));

    final libConfigAppConfiguration = File(
      '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}app_configuration.dart',
    );
    await libConfigAppConfiguration.create(recursive: true);
    await libConfigAppConfiguration.writeAsString(_libConfigAppConfigurationContent);

    final List<String> dependenciesKeys = variables['dependenciesKeys'] as List<String>? ?? [];
    final bool hasVadenSecurity = dependenciesKeys.contains('vaden_security');

    if (hasVadenSecurity) {
      final vadenSecurityVersion = variables['vaden_security'] ?? '^0.0.3';
      await fileManager.insertLineInFile(
        pubspec,
        RegExp(r'dependencies:'),
        '  vaden_security: $vadenSecurityVersion',
        position: InsertLinePosition.after,
      );

      final appModulePath =
          '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}app_module.dart';
      final libConfigAppModule = File(appModulePath);
      await libConfigAppModule.create(recursive: true);
      await libConfigAppModule.writeAsString(_libConfigAppModuleContent);
    }

    final libConfigResourcesResourceConfiguration = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}resources${Platform.pathSeparator}resource_configuration.dart',);
    await libConfigResourcesResourceConfiguration.create(recursive: true);
    await libConfigResourcesResourceConfiguration
        .writeAsString(_libConfigResourcesResourceConfigurationContent);

    final srcHelloController = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}src${Platform.pathSeparator}hello_controller.dart',);
    await srcHelloController.create(recursive: true);
    await srcHelloController.writeAsString(_srcHelloControllerContent);

    final libConfigAppControllerAdvice = File(
        '${directory.path}${Platform.pathSeparator}lib${Platform.pathSeparator}config${Platform.pathSeparator}app_controller_advice.dart',);
    await libConfigAppControllerAdvice.create(recursive: true);
    await libConfigAppControllerAdvice.writeAsString(_libConfigAppControllerAdviceContent);
  }
}

const _pubspecContent = '''name: {{name}}
description: {{description}}.
version: 1.0.0
# repository: https://github.com/my_org/my_repo

environment:
  sdk: ^{{dartVersion}}

dependencies:
  vaden: {{vaden}}

dev_dependencies:
  build_runner: {{build_runner}}
  vaden_class_scanner: {{vaden_class_scanner}}
''';

const _readmeContent = '''# {{name}}

{{description}}
''';

const _buildContent = r'''targets:
  $default:
    builders:
      vaden_class_scanner|aggregating_vaden_builder:
        enabled: true

''';

const _applicationContent = '''openapi:
  title: {{name}} API
  version: 1.0.0
  description: API gerada automaticamente pelo Vaden.
  enable: true

server:
  port: 8080
  host: localhost

storage:
  provider: local  # opções: local, s3, firebase
  local:
    folder: './uploads'
  s3:
    bucket: 'meu-bucket'
    region: 'us-east-1'
    accessKey: 'sua_access_key'
    secretKey: 'seu_secret_key'
  firebase:
    projectId: 'my-project'
    apiKey: 'my_api'

env:
  mode: debug

''';

const _dockerFileContent = '''
FROM dart:3.6.0 AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
WORKDIR /app
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/
EXPOSE 8080
CMD ["./server"]
''';

const _analysisOptionsContent = '''include: package:lints/recommended.yaml

# Uncomment the following section to specify additional rules.

# linter:
#   rules:
#     - camel_case_types

# analyzer:
#   exclude:
#     - path/to/excluded/files/**

# For more information about the core and recommended set of lints, see
# https://dart.dev/go/core-lints

# For additional information about configuring this file, see
# https://dart.dev/guides/language/analysis-options
''';

const _gitIgnoreContent = '''# https://dart.dev/guides/libraries/private-files
# Created by `dart pub`
.dart_tool/
lib/vaden_application.dart
''';

const _dockerIgnoreContent = '''.dockerignore
.dockerignore
Dockerfile
build/
.dart_tool/
.git/
.github/
.gitignore
.idea/
.packages
temp/
local/
.env
lib/vaden_application.dart
pubspec_overrides.yaml
''';

const _publicIndexContent = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>{{name}} Example</title>
</head>
<body>
    <h1>Welcome to {{name}}</h1>
    <p>This is an example page.</p>
</body>
</html>''';

const _binServerContent = r'''import 'package:{{name}}/vaden_application.dart';

void main() async {
  final vaden = VadenApplication();
  await vaden.setup();
  final server = await vaden.run();
  print('Server listening on port ${server.port}');
}

''';

const _libConfigAppConfigurationContent = '''import 'package:vaden/vaden.dart';

@Configuration()
class AppConfiguration {
  @Bean()
  ApplicationSettings settings() {
    return ApplicationSettings.load('application.yaml');
  }

  @Bean()
  Pipeline globalMiddleware(ApplicationSettings settings) {
    return Pipeline() //
        .addMiddleware(cors(allowedOrigins: ['*']))
        .addVadenMiddleware(EnforceJsonContentType())
        .addMiddleware(logRequests());
  }
}
''';

const _libConfigAppModuleContent = '''import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@VadenModule([VadenSecurity])
class AppModule {}

''';

const _libConfigResourcesResourceConfigurationContent = '''import 'package:vaden/vaden.dart';

@Configuration()
class ResourceConfiguration {
  @Bean()
  Storage configStorage(ApplicationSettings settings) {
    return Storage.createStorageService(settings);
  }

  @Bean()
  ResourceService resources() {
    return ResourceService(
      fileSystemPath: './public',
      defaultDocument: 'index.html',
    );
  }
}
''';

const _srcHelloControllerContent = '''import 'package:vaden/vaden.dart';

@Controller('/hello')
class HelloController {
  @Get('/ping')
  String ping() {
    return 'pong';
  }
}

''';

const _libConfigAppControllerAdviceContent = '''import 'dart:convert';

import 'package:vaden/vaden.dart';

@ControllerAdvice()
class AppControllerAdvice {
  final DSON _dson;
  AppControllerAdvice(this._dson);

  @ExceptionHandler(ResponseException)
  Future<Response> handleResponseException(ResponseException e) async {
    return e.generateResponse(_dson);
  }

  @ExceptionHandler(Exception)
  Response handleException(Exception e) {
    return Response.internalServerError(
      body: jsonEncode({
        'message': 'Internal server error',
      }),
    );
  }
}''';
