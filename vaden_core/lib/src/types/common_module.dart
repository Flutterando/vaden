import 'dart:async';

import 'package:vaden_core/vaden_core.dart';

/// The `CommonModule` abstract class defines the structure for creating modules
/// that can register their own dependency injections and route configurations.
/// This allows for modularization and better organization of code in a Vaden-based
/// application.
abstract class CommonModule<T extends VadenApplication> {
  /// The `register` method is responsible for defining the routes that
  /// the module provides. This method should be implemented by subclasses
  /// to define the specific routes required by the module.
  FutureOr<void> register(T application);
}
