// GENERATED CODE - DO NOT MODIFY BY HAND
// Aggregated Vaden application file
// ignore_for_file: prefer_func  tion_declarations_over_variables, implementation_imports
import 'package:domain/domain.dart';
import 'package:domain/models/default_message.dart';
import 'package:domain/models/todo.dart';

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dioPackage;
import 'package:flutter_vaden/flutter_vaden.dart';

late final AutoInjector _injector;

class VadenApp extends FlutterVadenApplication {
  @override
  AutoInjector get injector => _injector;

  VadenApp({required super.child, AutoInjector? injector}) {
    _injector = injector ?? AutoInjector();
  }

  @override
  Future<void> setup() async {
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);
    _injector.addInstance<Injector>(_injector);

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
      final runtimeType = json['runtimeType'] as String?;
      switch (runtimeType) {
        case 'TodoBase':
          return fromJson<TodoBase>(json);
        case 'TodoCreate':
          return fromJson<TodoCreate>(json);
        case 'TodoUpdate':
          return fromJson<TodoUpdate>(json);
        default:
          throw ArgumentError('Unknown runtimeType for Todo: $runtimeType');
      }
    };
    toJsonMap[Todo] = (object) {
      // Obtém o tipo real do objeto em runtime
      final objectType = object.runtimeType;
      switch (objectType) {
        case TodoBase:
          return toJson<TodoBase>(object as TodoBase);
        case TodoCreate:
          return toJson<TodoCreate>(object as TodoCreate);
        case TodoUpdate:
          return toJson<TodoUpdate>(object as TodoUpdate);
        default:
          throw ArgumentError('Unknown subtype for Todo: $objectType');
      }
    };
    toOpenApiMap[Todo] = {
      "oneOf": [
        {r"$ref": "#/components/schemas/TodoBase"},
        {r"$ref": "#/components/schemas/TodoCreate"},
        {r"$ref": "#/components/schemas/TodoUpdate"},
      ],
      "discriminator": {
        "propertyName": "runtimeType",
        "mapping": {
          "TodoBase": "#/components/schemas/TodoBase",
          "TodoCreate": "#/components/schemas/TodoCreate",
          "TodoUpdate": "#/components/schemas/TodoUpdate",
        },
      },
    };

    fromJsonMap[TodoCreate] = (Map<String, dynamic> json) {
      return Function.apply(TodoCreate.new, [], {
        #title: json['title'],
        #check: json['check'],
      });
    };
    toJsonMap[TodoCreate] = (object) {
      final obj = object as TodoCreate;
      return {
        'runtimeType': 'TodoCreate',
        'title': obj.title,
        'check': obj.check,
      };
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
