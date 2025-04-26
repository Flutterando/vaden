part of 'storage.dart';

/// Implementation of the [Storage] interface that uses the local file system.
///
/// The LocalStorage class provides file storage capabilities using the local file system.
/// It stores files in a specified folder on the server's file system, making it suitable
/// for development environments or applications with simple storage needs.
///
/// This implementation is the simplest of the storage providers and doesn't require any
/// external services or credentials. However, it has limitations such as:
/// - Files are only accessible from the server where they are stored
/// - No built-in redundancy or backup mechanisms
/// - Limited scalability compared to cloud storage solutions
///
/// Example usage:
/// ```dart
/// final storage = LocalStorage('uploads');
///
/// // Upload a file
/// final filePath = await storage.upload('image.jpg', imageBytes);
///
/// // The file will be stored at 'uploads/[generated-uuid].jpg'
/// ```
///
/// Configuration in application settings:
/// ```yaml
/// storage:
///   provider: 'local'
///   local:
///     folder: 'uploads'
/// ```
class LocalStorage extends Storage {
  /// The path to the folder where files will be stored.
  ///
  /// This path can be absolute or relative to the current working directory.
  /// The folder will be created if it doesn't exist when the first file is uploaded.
  final String folderPath;

  /// Creates a new LocalStorage instance with the specified folder path.
  ///
  /// Parameters:
  /// - [folderPath]: The path to the folder where files will be stored.
  LocalStorage(this.folderPath);

  /// Uploads a file to the local file system.
  ///
  /// This method generates a unique filename using UUID and the original file extension,
  /// creates the file in the specified folder, and writes the provided bytes to it.
  ///
  /// Parameters:
  /// - [filePath]: The original file path, used to extract the file extension.
  /// - [bytes]: The contents of the file as a byte array.
  ///
  /// Returns:
  /// - A Future that resolves to the unique filename of the uploaded file.
  ///
  /// Throws:
  /// - [FileSystemException]: If the file cannot be created or written to.
  @override
  Future<String> upload(String filePath, List<int> bytes) async {
    final extension = _extractExtension(filePath);
    final uniqueName = '${Uuid().v4()}.$extension';

    final file = File('$folderPath/$uniqueName');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return uniqueName;
  }

  /// Downloads a file from the local file system.
  ///
  /// This method reads the file at the specified path and returns its contents as a byte array.
  ///
  /// Parameters:
  /// - [filePath]: The path of the file to download, relative to the storage folder.
  ///
  /// Returns:
  /// - A Future that resolves to the contents of the file as a byte array.
  ///
  /// Throws:
  /// - [Exception]: If the file does not exist.
  /// - [FileSystemException]: If the file cannot be read.
  @override
  Future<List<int>> download(String filePath) async {
    final file = File('$folderPath/$filePath');
    if (await file.exists()) {
      return file.readAsBytes();
    }
    throw Exception('File not found: $filePath');
  }

  /// Deletes a file from the local file system.
  ///
  /// This method deletes the file at the specified path if it exists.
  /// If the file does not exist, the method completes successfully without any action.
  ///
  /// Parameters:
  /// - [filePath]: The path of the file to delete, relative to the storage folder.
  ///
  /// Returns:
  /// - A Future that completes when the file has been deleted or confirmed not to exist.
  ///
  /// Throws:
  /// - [FileSystemException]: If the file exists but cannot be deleted.
  @override
  Future<void> delete(String filePath) async {
    final file = File('$folderPath/$filePath');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Lists all files in a folder in the local file system.
  ///
  /// This method retrieves a list of file paths for all files in the specified folder.
  /// If the folder does not exist, an empty list is returned.
  ///
  /// Parameters:
  /// - [folder]: Optional. The path of the subfolder to list files from, relative to the storage folder.
  ///   If not provided, files in the root storage folder are listed.
  ///
  /// Returns:
  /// - A Future that resolves to a list of file paths, relative to the storage folder.
  ///
  /// Throws:
  /// - [FileSystemException]: If the directory exists but cannot be read.
  @override
  Future<List<String>> listFiles([String? folder]) async {
    final directory = Directory(
      folder == null ? folderPath : '$folderPath/$folder',
    );
    if (!await directory.exists()) {
      return [];
    }

    final items = await directory.list().toList();
    final filePaths = <String>[];
    for (final entity in items) {
      if (entity is File) {
        final relativePath = entity.path.replaceFirst('$folderPath/', '');
        filePaths.add(relativePath);
      }
    }
    return filePaths;
  }

  /// Extracts the file extension from a file path.
  ///
  /// This private helper method extracts the file extension from a file path by finding
  /// the last occurrence of a dot (.) and returning everything after it.
  ///
  /// For example, if the file path is "example.png", this method returns "png".
  /// If there is no dot in the file path, an empty string is returned.
  ///
  /// Parameters:
  /// - [filePath]: The file path to extract the extension from.
  ///
  /// Returns:
  /// - The file extension as a string, without the leading dot.
  String _extractExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    return (dotIndex == -1) ? '' : filePath.substring(dotIndex + 1);
  }
}
