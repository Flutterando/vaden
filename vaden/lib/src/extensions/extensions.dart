/// Extensions for the Vaden framework.
///
/// This library contains various extensions that enhance the functionality of
/// core classes in the Vaden framework and its dependencies. Extensions provide
/// a way to add functionality to existing classes without modifying their source code.
///
/// The extensions in this library are designed to make working with the Vaden framework
/// more convenient and expressive, reducing boilerplate code and improving readability.
///
/// Currently, this library includes:
/// - [PipelineExtension]: Extends the shelf [Pipeline] class with methods for adding
///   Vaden-specific middleware and guards.
///
/// Example usage:
/// ```dart
/// import 'package:vaden/vaden.dart';
///
/// void main() {
///   final handler = const Pipeline()
///     .addGuard(AuthGuard())
///     .addVadenMiddleware(LoggingMiddleware())
///     .addHandler(router);
///
///   // Start the server with the configured handler
///   serve(handler, 'localhost', 8080);
/// }
/// ```
library;

import 'package:vaden/vaden.dart';

part 'pipeline_extension.dart';
