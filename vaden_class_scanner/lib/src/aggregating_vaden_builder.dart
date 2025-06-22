import 'package:build/build.dart';
import 'package:vaden_class_scanner/src/backend_builder.dart';
import 'package:vaden_class_scanner/src/flutter_builder.dart';

Builder aggregatingVadenBuilder(BuilderOptions options) {
  final target = options.config['target'] as String? ?? 'backend';

  if (target == 'flutter') {
    return FlutterVadenBuilder();
  }

  return BackendVadenBuilder();
}
