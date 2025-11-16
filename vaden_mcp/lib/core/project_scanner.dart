import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'file_utils.dart';

/// Scanner for analyzing Vaden project structure
class ProjectScanner {
  final String projectRoot;

  ProjectScanner(this.projectRoot);

  /// Check if the current directory is a valid Vaden project
  Future<bool> isVadenProject() async {
    final pubspecPath = p.join(projectRoot, 'pubspec.yaml');
    if (!await FileUtils.fileExists(pubspecPath)) {
      return false;
    }

    try {
      final content = await FileUtils.readFile(pubspecPath);
      final pubspec = loadYaml(content);
      final dependencies = pubspec['dependencies'] as YamlMap?;
      return dependencies != null && dependencies.containsKey('vaden');
    } catch (e) {
      return false;
    }
  }

  /// Get project name from pubspec.yaml
  Future<String?> getProjectName() async {
    final pubspecPath = p.join(projectRoot, 'pubspec.yaml');
    try {
      final content = await FileUtils.readFile(pubspecPath);
      final pubspec = loadYaml(content);
      return pubspec['name'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Find all controllers in the project
  Future<List<String>> findControllers() async {
    return await _findFilesWithAnnotation('@Controller');
  }

  /// Find all services in the project
  Future<List<String>> findServices() async {
    return await _findFilesWithAnnotation('@Service');
  }

  /// Find all repositories in the project
  Future<List<String>> findRepositories() async {
    return await _findFilesWithAnnotation('@Repository');
  }

  /// Find all configurations in the project
  Future<List<String>> findConfigurations() async {
    return await _findFilesWithAnnotation('@Configuration');
  }

  /// Find all DTOs in the project
  Future<List<String>> findDTOs() async {
    return await _findFilesWithAnnotation('@DTO');
  }

  /// Find all modules in the project
  Future<List<String>> findModules() async {
    return await _findFilesWithAnnotation('@VadenModule');
  }

  /// Find files containing a specific annotation
  Future<List<String>> _findFilesWithAnnotation(String annotation) async {
    final libPath = p.join(projectRoot, 'lib');
    if (!await FileUtils.directoryExists(libPath)) {
      return [];
    }

    final dartFiles = await FileUtils.findFiles(libPath, '.dart');
    final matchingFiles = <String>[];

    for (final file in dartFiles) {
      try {
        final content = await FileUtils.readFile(file);
        if (content.contains(annotation)) {
          matchingFiles.add(file);
        }
      } catch (e) {
        // Skip files that can't be read
        continue;
      }
    }

    return matchingFiles;
  }

  /// Get application.yaml configuration
  Future<Map<String, dynamic>?> getApplicationConfig() async {
    final configPath = p.join(projectRoot, 'application.yaml');
    if (!await FileUtils.fileExists(configPath)) {
      return null;
    }

    try {
      final content = await FileUtils.readFile(configPath);
      final config = loadYaml(content);
      return _yamlToMap(config);
    } catch (e) {
      return null;
    }
  }

  /// Convert YamlMap to regular Map recursively
  Map<String, dynamic> _yamlToMap(dynamic yaml) {
    if (yaml is YamlMap) {
      final map = <String, dynamic>{};
      yaml.forEach((key, value) {
        map[key.toString()] = _yamlToMap(value);
      });
      return map;
    } else if (yaml is YamlList) {
      return {'list': yaml.map((e) => _yamlToMap(e)).toList()};
    } else {
      return {'value': yaml};
    }
  }

  /// Get project structure summary
  Future<Map<String, dynamic>> getProjectSummary() async {
    final controllers = await findControllers();
    final services = await findServices();
    final repositories = await findRepositories();
    final configurations = await findConfigurations();
    final dtos = await findDTOs();
    final modules = await findModules();

    return {
      'projectName': await getProjectName(),
      'isVadenProject': await isVadenProject(),
      'controllers': controllers.length,
      'services': services.length,
      'repositories': repositories.length,
      'configurations': configurations.length,
      'dtos': dtos.length,
      'modules': modules.length,
      'controllerFiles': controllers
          .map((f) => FileUtils.getRelativePath(projectRoot, f))
          .toList(),
      'serviceFiles': services
          .map((f) => FileUtils.getRelativePath(projectRoot, f))
          .toList(),
      'repositoryFiles': repositories
          .map((f) => FileUtils.getRelativePath(projectRoot, f))
          .toList(),
    };
  }

  /// Find main application file
  Future<String?> findMainApplicationFile() async {
    final candidates = [
      p.join(projectRoot, 'lib', 'vaden_application.dart'),
      p.join(projectRoot, 'lib', 'main.dart'),
    ];

    for (final candidate in candidates) {
      if (await FileUtils.fileExists(candidate)) {
        return candidate;
      }
    }

    // Search for files implementing DartVadenApplication
    final libPath = p.join(projectRoot, 'lib');
    final dartFiles = await FileUtils.findFiles(libPath, '.dart');

    for (final file in dartFiles) {
      final content = await FileUtils.readFile(file);
      if (content.contains('DartVadenApplication') ||
          content.contains('VadenApplication')) {
        return file;
      }
    }

    return null;
  }
}
