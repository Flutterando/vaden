import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:backend/src/core/files/file_generate.dart';
import 'package:backend/src/core/files/generators/cron.dart';
import 'package:backend/src/core/files/generators/dio.dart';
import 'package:backend/src/core/files/generators/initial_project.dart';
import 'package:backend/src/core/files/generators/openapi.dart';
import 'package:backend/src/core/files/generators/postgres.dart';
import 'package:backend/src/core/files/generators/redis.dart';
import 'package:backend/src/core/files/generators/sqlite.dart';
import 'package:backend/src/core/files/generators/websocket.dart';
import 'package:uuid/uuid.dart';
import 'package:vaden/vaden.dart';

enum InsertLinePosition { before, after }

@Component()
class FileManager {
  final _generators = <String, FileGenerator>{
    'initial_project': InitialProjectGenerator(),
    'openapi': OpenAPIGenerator(),
    'websocket': WebsocketGenerator(),
    'dio': DioGenerator(),
    'redis': RedisGenerator(),
    'postgres': PostgresGenerator(),
    'sqlite': SqliteGenerator(),
    'cron': CronGenerator(),
  };

  Future<Directory> createTempDir(Directory dir, String name) {
    final tempDirName = Uuid().v4();

    return Directory(
      '${dir.path}${Platform.pathSeparator}$tempDirName${Platform.pathSeparator}$name',
    ).create(recursive: true);
  }

  FileGenerator? getGenerator(String key) {
    return _generators[key];
  }

  Future<void> insertLineInFile(
    File file,
    RegExp line,
    String content, {
    InsertLinePosition position = InsertLinePosition.after,
  }) async {
    final lines = await file.readAsLines();
    final index = lines.indexWhere((element) => line.hasMatch(element));

    if (index == -1) {
      throw Exception('Line not found');
    }

    final newLines = <String>[];

    for (var i = 0; i < lines.length; i++) {
      newLines.add(lines[i]);

      if (i == index) {
        if (position == InsertLinePosition.after) {
          newLines.add(content);
        } else {
          newLines.insert(i, content);
        }
      }
    }

    await file.writeAsString(newLines.join('\n'));
  }

  Future<List<int>> createZip(String folderPath, String projectName) async {
    final archive = Archive();

    final files = Directory(folderPath) //
    .listSync(recursive: true) //
    .whereType<File>() //
    .toList();

    for (var file in files) {
      final fileBytes = await file.readAsBytes();
      final relativePath = file.path.substring(folderPath.length + 1);
      archive.addFile(ArchiveFile(relativePath, fileBytes.length, fileBytes));
    }

    return ZipEncoder().encode(archive);
  }
}
