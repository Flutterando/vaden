import 'dart:io';
import 'package:path/path.dart' as p;

/// Utilities for safe file reading and writing in Vaden projects
class FileUtils {
  /// Read file content safely
  static Future<String> readFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File not found: $path');
      }
      return await file.readAsString();
    } catch (e) {
      throw Exception('Error reading file $path: $e');
    }
  }

  /// Write content to file safely
  static Future<void> writeFile(String path, String content) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    } catch (e) {
      throw Exception('Error writing file $path: $e');
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Check if directory exists
  static Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  /// List files in directory with optional pattern
  static Future<List<String>> listFiles(
    String directory, {
    String? pattern,
    bool recursive = false,
  }) async {
    final dir = Directory(directory);
    if (!await dir.exists()) {
      return [];
    }

    final files = <String>[];
    await for (final entity in dir.list(recursive: recursive)) {
      if (entity is File) {
        final path = entity.path;
        if (pattern == null || path.endsWith(pattern)) {
          files.add(path);
        }
      }
    }
    return files;
  }

  /// Find files matching pattern recursively
  static Future<List<String>> findFiles(
    String directory,
    String pattern,
  ) async {
    return await listFiles(directory, pattern: pattern, recursive: true);
  }

  /// Get relative path from project root
  static String getRelativePath(String projectRoot, String filePath) {
    return p.relative(filePath, from: projectRoot);
  }

  /// Ensure directory exists
  static Future<void> ensureDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Create file with content if it doesn't exist
  static Future<bool> createFileIfNotExists(
    String path,
    String content,
  ) async {
    if (await fileExists(path)) {
      return false;
    }
    await writeFile(path, content);
    return true;
  }

  /// Append content to file
  static Future<void> appendToFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content, mode: FileMode.append);
  }

  /// Read file as lines
  static Future<List<String>> readLines(String path) async {
    final content = await readFile(path);
    return content.split('\n');
  }

  /// Insert content at specific line
  static Future<void> insertAtLine(
    String path,
    int lineNumber,
    String content,
  ) async {
    final lines = await readLines(path);
    if (lineNumber < 0 || lineNumber > lines.length) {
      throw Exception('Invalid line number: $lineNumber');
    }
    lines.insert(lineNumber, content);
    await writeFile(path, lines.join('\n'));
  }

  /// Replace line at specific index
  static Future<void> replaceLine(
    String path,
    int lineNumber,
    String newContent,
  ) async {
    final lines = await readLines(path);
    if (lineNumber < 0 || lineNumber >= lines.length) {
      throw Exception('Invalid line number: $lineNumber');
    }
    lines[lineNumber] = newContent;
    await writeFile(path, lines.join('\n'));
  }
}
