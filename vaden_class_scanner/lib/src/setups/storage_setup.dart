import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vaden_core/vaden_core.dart';

final storageKeyChecker = TypeChecker.fromRuntime(StorageKey);
final storageObjectChecker = TypeChecker.fromRuntime(StorageObject);

String storageClientSetup(ClassElement classElement) {
  final buffer = StringBuffer();

  buffer
      .writeln('class _${classElement.name} implements ${classElement.name} {');
  buffer.writeln('  final DSON dson;');
  buffer.writeln('  _${classElement.name}(this.dson);');

  for (final method in classElement.methods) {
    buffer.writeln('  @override');
    final methodName = method.name;
    final returnType = _getFutureType(method.returnType);
    final isVoidReturn =
        returnType.getDisplayString(withNullability: false) == 'void';
    final parameters = method.parameters;

    final parameterList = parameters.map((param) {
      final type = param.type.getDisplayString(withNullability: true);
      return '${param.isNamed ? '' : type} ${param.name}';
    }).join(', ');

    // Descobrir a chave
    final storageKeyAnn = method.metadata.firstWhereOrNull((m) {
      final type = m.computeConstantValue()?.type;
      return type != null && storageKeyChecker.isExactlyType(type);
    });
    String? storageKey;
    if (storageKeyAnn != null) {
      final ann = storageKeyAnn.computeConstantValue();
      storageKey = ann?.getField('name')?.toStringValue();
    }
    storageKey ??= methodName;

    // Descobrir se é objeto
    final isObject = method.metadata.any((m) {
      final type = m.computeConstantValue()?.type;
      return type != null && storageObjectChecker.isExactlyType(type);
    });

    buffer.writeln('  Future<$returnType> $methodName($parameterList) async {');
    buffer.writeln('    final prefs = _injector.tryGet<ILocalStorage>();\n');

    buffer.writeln('    if (prefs == null) {\n');
    buffer.writeln('      throw Exception("ILocalStorage not found");\n');
    buffer.writeln('    }\n');

    if (methodName.startsWith('set')) {
      // Setter
      final valueParam = parameters.first;
      final valueName = valueParam.name;

      if (valueParam.type.isDartCoreBool) {
        buffer.writeln("    await prefs.setBool('$storageKey', $valueName);");
      } else if (valueParam.type.isDartCoreInt) {
        buffer.writeln("    await prefs.setInt('$storageKey', $valueName);");
      } else if (valueParam.type.isDartCoreDouble) {
        buffer.writeln("    await prefs.setDouble('$storageKey', $valueName);");
      } else if (valueParam.type.isDartCoreString) {
        buffer.writeln("    await prefs.setString('$storageKey', $valueName);");
      } else if (isObject && returnType.isDartCoreList) {
        final listType = _getListType(returnType);
        buffer.writeln(
            'await prefs.setString(\'$storageKey\', json.encode(dson.toJsonList<$listType>($valueName)));');
      } else if (isObject && !returnType.isDartCoreList) {
        buffer.writeln(
            'await prefs.setString(\'$storageKey\', json.encode(dson.toJson<$returnType>($valueName)));');
      } else {
        buffer.writeln('    // Método não suportado: $methodName');
        buffer.writeln('    return;');
      }

      if (!isVoidReturn) {
        buffer.writeln('    return $valueName;');
      }
    } else if (methodName.startsWith('get')) {
      // Getter
      if (returnType.isDartCoreBool) {
        buffer.writeln("    return await prefs.getBool('$storageKey');");
      } else if (returnType.isDartCoreInt) {
        buffer.writeln("    return await prefs.getInt('$storageKey');");
      } else if (returnType.isDartCoreDouble) {
        buffer.writeln("    return await prefs.getDouble('$storageKey');");
      } else if (returnType.isDartCoreString) {
        buffer.writeln("    return await prefs.getString('$storageKey');");
      } else if (isObject && returnType.isDartCoreList) {
        final listType = _getListType(returnType);
        buffer
            .writeln('final result = await prefs.getString(\'$storageKey\');');
        buffer.writeln('   if (result == null || result.isEmpty) {');
        buffer.writeln('     return null;');
        buffer.writeln('   }');
        buffer.writeln(
            'return dson.fromJsonList<$listType>(json.decode(result));');
      } else if (isObject && !returnType.isDartCoreList) {
        buffer
            .writeln('final result = await prefs.getString(\'$storageKey\');');
        buffer.writeln('   if (result == null || result.isEmpty) {');
        buffer.writeln('     return null;');
        buffer.writeln('   }');
        buffer
            .writeln('return dson.fromJson<$returnType>(json.decode(result));');
      } else {
        buffer.writeln('    // Método não suportado: $methodName');
        buffer.writeln('    return;');
      }
    } else {
      buffer.writeln('    // Método não suportado: $methodName');
      if (!isVoidReturn) {
        buffer.writeln('    return null;');
      }
    }
    buffer.writeln('  }');
  }

  buffer.writeln('}');
  return buffer.toString();
}

DartType _getFutureType(DartType type) {
  if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
    return type is InterfaceType ? type.typeArguments.first : type;
  }
  return type;
}

DartType _getListType(DartType type) {
  if (type.isDartCoreList) {
    return type is InterfaceType ? type.typeArguments.first : type;
  }
  return type;
}
