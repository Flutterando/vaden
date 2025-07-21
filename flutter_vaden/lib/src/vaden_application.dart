import 'package:flutter/material.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

abstract class FlutterVadenApplication extends StatefulWidget {
  final Widget child;
  const FlutterVadenApplication({super.key, required this.child});

  Injector get injector;

  Future<void> setup();

  @override
  State<FlutterVadenApplication> createState() =>
      _FlutterVadenApplicationState();
}

class _FlutterVadenApplicationState extends State<FlutterVadenApplication> {
  var _isSetup = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await widget.setup();
    setState(() {
      _isSetup = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isSetup) {
      return InheritedAutoInjector(
        injector: widget.injector,
        child: widget.child,
      );
    }

    return const SizedBox.shrink();
  }
}

class InheritedAutoInjector extends InheritedWidget {
  final Injector injector;

  const InheritedAutoInjector({
    super.key,
    required this.injector,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedAutoInjector oldWidget) {
    return oldWidget.injector != injector;
  }

  static Injector of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedAutoInjector>();
    if (inherited == null) {
      throw Exception('No AutoInjector found in context');
    }
    return inherited.injector;
  }
}

extension BuildContextInjectorExtension on BuildContext {
  T read<T extends Object>() {
    final injector = InheritedAutoInjector.of(this);
    return injector<T>();
  }
}

abstract class ILocalStorage {
  Future<bool?> getBool(String key);
  Future<int?> getInt(String key);
  Future<double?> getDouble(String key);
  Future<String?> getString(String key);

  Future<bool> setBool(String key, bool value);
  Future<bool> setInt(String key, int value);
  Future<bool> setDouble(String key, double value);
  Future<bool> setString(String key, String value);
}
