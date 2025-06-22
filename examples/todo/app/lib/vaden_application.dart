// GENERATED CODE - DO NOT MODIFY BY HAND
// Aggregated Vaden application file
// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports
import 'package:domain/domain.dart';
import 'package:flutter_vaden/flutter_vaden.dart';

late final AutoInjector _injector;

class VadenApp extends FlutterVadenApplication {
  @override
  AutoInjector get injector => _injector;

  VadenApp({super.key, required super.child, AutoInjector? injector}) {
    _injector = injector ?? AutoInjector();
  }

  @override
  Future<void> setup() async {
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);

    _injector.commit();

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }
  }
}

class _DSON extends DSON {
  @override
  (
    Map<Type, FromJsonFunction>,
    Map<Type, ToJsonFunction>,
    Map<Type, ToOpenApiNormalMap>,
  )
  getMaps() {
    final fromJsonMap = <Type, FromJsonFunction>{};
    final toJsonMap = <Type, ToJsonFunction>{};
    final toOpenApiMap = <Type, ToOpenApiNormalMap>{};

    fromJsonMap[DefaultMessage] = (Map<String, dynamic> json) {
      return Function.apply(DefaultMessage.new, [], {
        #message: json['message'],
      });
    };
    toJsonMap[DefaultMessage] = (object) {
      final obj = object as DefaultMessage;
      return {'message': obj.message};
    };
    toOpenApiMap[DefaultMessage] = {
      "type": "object",
      "properties": <String, dynamic>{
        "message": {"type": "string"},
      },
      "required": ["message"],
    };

    fromJsonMap[Todo] = (Map<String, dynamic> json) {
      return Function.apply(Todo.new, [], {
        #id: json['id'],
        #title: json['title'],
        #check: json['check'],
      });
    };
    toJsonMap[Todo] = (object) {
      final obj = object as Todo;
      return {'id': obj.id, 'title': obj.title, 'check': obj.check};
    };
    toOpenApiMap[Todo] = {
      "type": "object",
      "properties": <String, dynamic>{
        "id": {"type": "integer"},
        "title": {"type": "string"},
        "check": {"type": "boolean"},
      },
      "required": ["id", "title", "check"],
    };

    fromJsonMap[TodoCreate] = (Map<String, dynamic> json) {
      return Function.apply(TodoCreate.new, [], {
        #title: json['title'],
        #check: json['check'],
      });
    };
    toJsonMap[TodoCreate] = (object) {
      final obj = object as TodoCreate;
      return {'title': obj.title, 'check': obj.check};
    };
    toOpenApiMap[TodoCreate] = {
      "type": "object",
      "properties": <String, dynamic>{
        "title": {"type": "string"},
        "check": {"type": "boolean"},
      },
      "required": ["title", "check"],
    };

    return (fromJsonMap, toJsonMap, toOpenApiMap);
  }
}
